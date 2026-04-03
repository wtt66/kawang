<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Lock, User } from '@element-plus/icons-vue'
import { login } from '@/api/auth'

const router = useRouter()
const loading = ref(false)
const form = reactive({
  username: '',
  password: '',
})

async function submit() {
  if (!form.username.trim() || !form.password.trim()) {
    ElMessage.warning('璇疯緭鍏ョ敤鎴峰悕鍜屽瘑鐮?)
    return
  }
  loading.value = true
  try {
    await login(form.username.trim(), form.password)
    ElMessage.success('鐧诲綍鎴愬姛')
    router.push('/products')
  } catch (error: any) {
    ElMessage.error(error?.response?.data?.message ?? '鐧诲綍澶辫触')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-shell">
    <div class="login-hero">
      <p class="login-eyebrow">KAWANG CONTROL</p>
      <h1>AI 浼氬憳鍟嗗煄鍚庡彴</h1>
      <p>缁熶竴绠＄悊鍟嗗搧銆佽处鍙锋睜鍜岃鍗曠姸鎬併€傛晱鎰熻处鍙蜂粎鍦ㄥ悗绔姞瀵嗗瓨鍌紝鍓嶅彴涓嶇洿鎺ユ毚闇层€?/p>
    </div>

    <el-card class="login-card" shadow="never">
      <template #header>
        <div>
          <h2>绠＄悊鍛樼櫥褰?/h2>
          <p class="muted">鐧诲綍鍚庤繘鍏ュ晢鍝併€佽处鍙蜂笌璁㈠崟绠＄悊鍙般€?/p>
        </div>
      </template>

      <el-form label-position="top">
        <el-form-item label="鐢ㄦ埛鍚?>
          <el-input v-model="form.username" placeholder="绠＄悊鍛樼敤鎴峰悕">
            <template #prefix><el-icon><User /></el-icon></template>
          </el-input>
        </el-form-item>
        <el-form-item label="瀵嗙爜">
          <el-input v-model="form.password" type="password" show-password placeholder="绠＄悊鍛樺瘑鐮?>
            <template #prefix><el-icon><Lock /></el-icon></template>
          </el-input>
        </el-form-item>
      </el-form>

      <el-button type="primary" class="login-button" :loading="loading" @click="submit">杩涘叆鍚庡彴</el-button>
    </el-card>
  </div>
</template>

<style scoped>
.login-shell {
  min-height: 100vh;
  display: grid;
  grid-template-columns: minmax(0, 1.2fr) minmax(360px, 420px);
  gap: 24px;
  align-items: center;
  width: min(1180px, calc(100vw - 32px));
  margin: 0 auto;
}

.login-hero {
  padding: 32px;
  border-radius: 32px;
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.96), rgba(8, 126, 164, 0.92));
  color: #fff;
  box-shadow: 0 24px 60px rgba(15, 23, 42, 0.16);
}

.login-eyebrow {
  margin: 0;
  font-size: 12px;
  letter-spacing: 0.24em;
  color: #8bd5ff;
}

.login-hero h1 {
  margin: 14px 0;
  font-size: clamp(34px, 5vw, 60px);
  line-height: 1.04;
}

.login-hero p:last-child {
  margin: 0;
  max-width: 520px;
  font-size: 16px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.8);
}

.login-card {
  border: none;
  border-radius: 28px;
  box-shadow: 0 18px 50px rgba(15, 23, 42, 0.1);
}

.login-card h2 {
  margin: 0 0 8px;
}

.login-button {
  width: 100%;
}

@media (max-width: 900px) {
  .login-shell {
    grid-template-columns: 1fr;
    padding: 24px 0;
  }
}
</style>

