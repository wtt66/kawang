<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAccounts, resetAccountGiftState, type AccountRecord } from '@/api/accounts'
import { getProducts, type ProductRecord } from '@/api/products'

const loading = ref(false)
const products = ref<ProductRecord[]>([])
const accounts = ref<AccountRecord[]>([])

const filters = reactive({
  productId: undefined as number | undefined,
  enableStatus: '',
  giftUseStatus: undefined as number | undefined,
  keyword: '',
})

const filteredAccounts = computed(() => {
  const keyword = filters.keyword.trim().toLowerCase()
  if (!keyword) {
    return accounts.value
  }
  return accounts.value.filter((item) => {
    return [item.cardKey, item.productTitle, item.giftAccount, item.giftErrorMessage ?? '']
      .join(' ')
      .toLowerCase()
      .includes(keyword)
  })
})

async function loadBaseData() {
  products.value = await getProducts()
  await loadAccounts()
}

async function loadAccounts() {
  loading.value = true
  try {
    accounts.value = await getAccounts(undefined, undefined, filters.enableStatus, filters.giftUseStatus)
    if (filters.productId) {
      accounts.value = accounts.value.filter((item) => item.productId === filters.productId)
    }
  } finally {
    loading.value = false
  }
}

function giftStatusLabel(useStatus: number) {
  switch (useStatus) {
    case 1:
      return '已完成'
    case -1:
      return '处理中'
    case -9:
      return '库存不足'
    case -999:
      return '异常'
    case -1000:
      return '已作废'
    default:
      return '待提交'
  }
}

function giftStatusType(useStatus: number) {
  switch (useStatus) {
    case 1:
      return 'success'
    case -1:
      return 'warning'
    case 0:
      return 'info'
    default:
      return 'danger'
  }
}

function statusHint(row: AccountRecord) {
  if (row.giftUseStatus === 1) return '充值已完成 上号查看吧~'
  if (row.giftUseStatus === -1) return '正在领取中 请稍后再查询'
  if (row.giftCooldownUntil) return `冷却至 ${row.giftCooldownUntil}`
  if (row.giftErrorMessage) return row.giftErrorMessage
  if (row.giftUseStatus === -9) return '礼物库存不足，请等待15分钟后再试或联系管理员补货'
  if (row.giftUseStatus === -999) return 'CDK异常 请联系客服处理'
  if (row.giftUseStatus === -1000) return 'CDK已作废 请联系客服处理'
  return '待提交'
}

function canResetGift(row: AccountRecord) {
  return !row.assignedOrderId && (
    row.giftUseStatus !== 0 ||
    !!row.giftAccount ||
    !!row.giftCompletedAt ||
    !!row.giftCooldownUntil ||
    !!row.giftErrorMessage
  )
}

async function resetGift(row: AccountRecord) {
  try {
    await ElMessageBox.confirm(
      `确定重置卡密“${row.cardKey}”的 Gift 状态吗？这会清空已记录的激活账号与完成时间。`,
      '重置 Gift 状态',
      {
        type: 'warning',
        confirmButtonText: '确认重置',
        cancelButtonText: '取消',
      },
    )
    await resetAccountGiftState(row.id)
    ElMessage.success('Gift 状态已重置')
    await loadAccounts()
  } catch (error: any) {
    if (error === 'cancel' || error === 'close') {
      return
    }
    ElMessage.error(error?.response?.data?.message ?? 'Gift 状态重置失败')
  }
}

async function copyText(text: string, label: string) {
  try {
    await navigator.clipboard.writeText(text)
    ElMessage.success(`${label}已复制`)
  } catch {
    ElMessage.error(`${label}复制失败`)
  }
}

onMounted(loadBaseData)
</script>

<template>
  <div class="admin-page">
    <el-card class="page-card" shadow="never">
      <div class="page-header">
        <div>
          <p>查看 Gift/CDKEY 的激活状态、绑定账号、冷却信息，并按需重置 Gift 激活记录。</p>
          <h1>Gift/CDKEY 管理</h1>
        </div>
        <div class="page-header__actions">
          <el-button @click="loadAccounts">刷新列表</el-button>
        </div>
      </div>

      <div class="toolbar gift-toolbar">
        <el-select v-model="filters.productId" clearable placeholder="按商品筛选" @change="loadAccounts">
          <el-option v-for="item in products" :key="item.id" :label="item.title" :value="item.id" />
        </el-select>
        <el-select v-model="filters.enableStatus" clearable placeholder="按启用状态筛选" @change="loadAccounts">
          <el-option label="启用" value="ENABLED" />
          <el-option label="停用" value="DISABLED" />
        </el-select>
        <el-select v-model="filters.giftUseStatus" clearable placeholder="按 Gift 状态筛选" @change="loadAccounts">
          <el-option label="待提交" :value="0" />
          <el-option label="处理中" :value="-1" />
          <el-option label="已完成" :value="1" />
          <el-option label="库存不足" :value="-9" />
          <el-option label="异常" :value="-999" />
          <el-option label="已作废" :value="-1000" />
        </el-select>
        <el-input v-model="filters.keyword" clearable placeholder="搜索卡密 / 商品 / 账号 / 错误信息" />
      </div>

      <el-table :data="filteredAccounts" v-loading="loading" border>
        <el-table-column prop="productTitle" label="所属商品" min-width="180" />
        <el-table-column label="卡密" min-width="250">
          <template #default="{ row }">
            <div class="gift-key-cell">
              <span>{{ row.cardKey }}</span>
              <el-button link type="primary" @click="copyText(row.cardKey, '卡密')">复制</el-button>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="Gift 状态" width="120">
          <template #default="{ row }">
            <el-tag :type="giftStatusType(row.giftUseStatus)">{{ giftStatusLabel(row.giftUseStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态说明" min-width="240">
          <template #default="{ row }">
            <span>{{ statusHint(row) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="激活账号" min-width="180">
          <template #default="{ row }">
            <span v-if="row.giftAccount">{{ row.giftAccount }}</span>
            <span v-else class="muted">未绑定</span>
          </template>
        </el-table-column>
        <el-table-column prop="giftCompletedAt" label="完成时间" min-width="180" />
        <el-table-column prop="giftCooldownUntil" label="冷却截止" min-width="180" />
        <el-table-column label="商城绑定订单" width="120">
          <template #default="{ row }">
            {{ row.assignedOrderId ?? '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="enableStatus" label="启用状态" width="100" />
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button link type="warning" :disabled="!canResetGift(row)" @click="resetGift(row)">重置 Gift</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.page-header__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.gift-toolbar {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.gift-key-cell {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

@media (max-width: 1180px) {
  .gift-toolbar {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 760px) {
  .gift-toolbar {
    grid-template-columns: 1fr;
  }
}
</style>
