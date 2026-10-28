<template>
  <q-page padding>
    <q-card>
      <q-card-actions>
        <q-btn
          flat
          no-caps
          icon="arrow_back"
          to="/admin/customers"
          label="Cadastrar cliente"
        />
      </q-card-actions>
      <q-card-section>
        <customer-form
          v-model="customer"
          @submit="saveCustomer"
        />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import CustomerForm from '@/components/CustomerForm.vue'
import { ref } from 'vue'
import { createCustomer } from './_api'
import { Notify } from 'quasar'
import { useRouter } from 'vue-router'

const router = useRouter()

const customer = ref({
  name: '',
  email: '',
  phone: '',
  birth_date: null,
  saving: false,
})

const saveCustomer = () => {
  customer.value.saving = true
  createCustomer(customer.value).then((data) => {
    Notify.create('Cliente cadastrado!')
    router.push(`/admin/customers/${data.id}`)
  }).finally(() => {
    customer.value.saving = false
  })
}
</script>
