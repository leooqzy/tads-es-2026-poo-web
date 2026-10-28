
<template>
  <q-page padding>
    <div class="row items-center justify-between q-mb-md">
      <div class="text-h5">Clientes</div>

      <q-btn
        color="primary"
        icon="add"
        label="Novo cliente"
        to="/admin/customers/create"
      />
    </div>

    <q-table
      title="Clientes cadastrados"
      :rows="customers"
      :columns="columns"
      row-key="id"
      :loading="loading"
    >
      <template v-slot:body-cell-actions="props">
        <q-td :props="props" class="q-gutter-sm">
          <q-btn
            flat
            round
            color="primary"
            icon="edit"
            :to="`/admin/customers/${props.row.id}`"
          >
            <q-tooltip>Editar cliente</q-tooltip>
          </q-btn>

          <q-btn
            flat
            round
            color="negative"
            icon="delete"
            @click="confirmDelete(props.row)"
          >
            <q-tooltip>Excluir cliente</q-tooltip>
          </q-btn>
        </q-td>
      </template>
    </q-table>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api } from '@/boot/axios'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const customers = ref([])
const loading = ref(false)

const columns = [
  { name: 'id', label: 'ID', field: 'id', align: 'left', sortable: true },
  { name: 'name', label: 'Nome', field: 'name', align: 'left', sortable: true },
  { name: 'email', label: 'E-mail', field: 'email', align: 'left' },
  { name: 'phone', label: 'Telefone', field: 'phone', align: 'left' },
  { name: 'birth_date', label: 'Nascimento', field: 'birth_date', align: 'left' },
  { name: 'actions', label: 'Ações', field: 'actions', align: 'center' },
]

async function loadCustomers() {
  loading.value = true

  try {
    const response = await api.get('/customers')

    customers.value = response.data.data ?? response.data
  } catch (error) {
    console.error('Erro ao carregar clientes:', error)
    $q.notify({
      type: 'negative',
      message: 'NÃ£o foi possÃ­vel carregar os clientes',
    })
  } finally {
    loading.value = false
  }
}

function confirmDelete(customer) {
  $q.dialog({
    title: 'Excluir cliente',
    message: `Deseja realmente excluir ${customer.name}?`,
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      await api.delete(`/customers/${customer.id}`)

      $q.notify({
        type: 'positive',
        message: 'Cliente excluÃ­do com sucesso',
      })

      await loadCustomers()
    } catch (error) {
      console.error('Erro ao excluir cliente:', error)
      $q.notify({
        type: 'negative',
        message: 'NÃ£o foi possÃ­vel excluir o cliente',
      })
    }
  })
}

onMounted(loadCustomers)
</script>

