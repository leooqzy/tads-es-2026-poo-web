<template>
  <q-page>
    <!-- Logout Page -->
  </q-page>
</template>

<script setup>
import { Dialog, LocalStorage } from 'quasar'
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

onMounted(() => {
  Dialog.create({
    message: 'Sair do sistema?',
    persistent: true,
    ok: 'Sair',
    cancel: 'Cancelar',
  }).onOk(() => {
    LocalStorage.removeItem('auth_data')
    router.push('/login')
  }).onCancel(() => {
    router.push('/admin/products')
  }).onDismiss((v) => {
    if (v === 'cancel') {
      router.push('/admin/products')
    }
  })
})
</script>
