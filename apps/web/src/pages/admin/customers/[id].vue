<template>
  <q-page padding>
    <q-card v-if="customer?.id">
      <q-card-actions>
        <q-btn
          flat
          no-caps
          icon="arrow_back"
          to="/admin/customers"
          label="Editar cliente"
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
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { getCustomer, updateCustomer } from './_api'
import { Notify } from 'quasar'

const route = useRoute()

const customer = ref(null)

const saveCustomer = () => {
  customer.value.saving = true
  updateCustomer(customer.value.id, customer.value).then(() => {
    Notify.create('Cliente atualizado!')
  }).finally(() => {
    customer.value.saving = false
  })
}

onMounted(() => {
  getCustomer(route.params.id).then((data) => {
    const customerData = data?.data ?? data
    customer.value = {
      ...customerData,
      birth_date: customerData.birth_date
        ? String(customerData.birth_date).substring(0, 10)
        : null,
      saving: false,
    }
  })
})
</script>
