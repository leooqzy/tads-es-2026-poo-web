<template>
  <q-layout>
    <q-page-container>
      <q-page class="flex flex-center">
        <div class="full-width row justify-center">
          <div class="col-12 col-md-4 col-lg-3">
            <q-card>
              <q-card-section class="text-weight-bold bg-grey-1">
                Acessar
              </q-card-section>
              <q-card-section>
                <q-form class="q-gutter-y-lg" @submit="onSubmit">
                  <q-input
                    required
                    label="Login"
                    type="email"
                    v-model="username"
                  />
                  <q-input
                    required
                    label="Senha"
                    type="password"
                    v-model="password"
                  />
                  <q-btn
                    flat
                    :loading="loading"
                    type="submit"
                    class="full-width"
                    label="Acessar"
                    icon="arrow_forward"
                  />
                </q-form>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref } from 'vue'
import { api } from '@/boot/axios'
import { LocalStorage, Notify } from 'quasar'
import { useRouter } from 'vue-router'

const router = useRouter()

const loading = ref(false)
const username = ref(null)
const password = ref(null)

const onSubmit = () => {
  loading.value = true

  api.post('auth/login', {
    email: username.value,
    password: password.value,
  }).then(({ data }) => {
    Notify.create('Login efetuado com sucesso!')
    LocalStorage.setItem('auth_data', data)
    router.push('/admin/products')
  }).catch((e) => {
    const message = e?.response?.data?.message ?? 'Falha no login'
    Notify.create({
      type: 'negative',
      message,
    })
  }).finally(() => {
    loading.value = false
  })
}
</script>
