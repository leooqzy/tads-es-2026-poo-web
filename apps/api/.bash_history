clear
./vendor/bin/pest
clear
exit
exit
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan make:seed UserSeeder
php artisan make:request AuthLoginRequest
php artisan make:controller AuthController
php artisan route:list
docker-compose ps
docker compose exec mysql mysql -u app_user -p
php artisan make:seeder UserSeeder
php artisan db:seed
docker compose exec php php artisan tinker
exit
php artisan route:list
docker compose exerc php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan route:clear
docker compose exec php php artisan config:clear
docker compose exec php php artisan cache:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear
exit
php artisan route:list
exit
clear
clear
exit
composer require dedoc/scramble
php artisan --version
php artisan vendor:publish --
provider="Dedoc\Scramble\ScrambleServiceProvider" --tag="scramble-config"
php artisan vendor:publish --provider="Dedoc\Scramble\ScrambleServiceProvider" --tag="scramble-config"
php artisan migrate:fresh --seed
php artisan tinker
php artisan tinker
exit
composer install
docker exec -it poo_web_quasar bash
clear
exit
[200~php artisan route:list | grep auth~
php artisan route:list | grep auth
php artisan route:list | grep customers
docker ps
docker exec -it poo_web_quasar bash
exit
   cat app/Http/Controllers/AuthController.php
exit
docker exec -it poo_web_php bash
cat app/Models/Customer.php
ls database/migrations | grep customer
@'
import { api } from "@/boot/axios"

export const getCustomers = (params = {}) => {
  return api.get('/customers', { params }).then(({ data }) => data)
}

export const createCustomer = (params = {}) => {
  return api.post('/customers', params).then(({ data }) => data)
}

export const getCustomer = (id) => {
  return api.get(`/customers/${id}`).then(({ data }) => data)
}

export const updateCustomer = (id, params = {}) => {
  return api.put(`/customers/${id}`, params).then(({ data }) => data)
}

export const deleteCustomer = (id) => {
  return api.delete(`/customers/${id}`).then(({ data }) => data)
}
'@ | Set-Content -LiteralPath apps/web/src/pages/admin/customers/_api.js -Encoding utf8
@'
<template>
  <q-form class="q-gutter-y-md">
    <q-input
      outlined
      stack-label
      required
      label="Nome"
      v-model="customer.name"
    />
    <q-input
      outlined
      stack-label
      required
      type="email"
      label="E-mail"
      v-model="customer.email"
    />
    <q-input
      outlined
      stack-label
      label="Telefone"
      v-model="customer.phone"
    />
    <q-input
      outlined
      stack-label
      type="date"
      label="Data de nascimento"
      v-model="customer.birth_date"
    />
    <div class="full-width bg-grey-1 q-py-md">
      <q-btn-group spread flat>
        <q-btn
          flat
          no-caps
          :loading="customer.saving"
          type="submit"
          label="Salvar"
          icon="save"
          color="positive"
        />
      </q-btn-group>
    </div>
  </q-form>
</template>

<script setup>
const customer = defineModel({
  default: () => ({
    id: null,
    name: null,
    email: null,
    phone: null,
    birth_date: null,
    saving: false,
  }),
})
</script>
'@ | Set-Content -LiteralPath apps/web/src/components/CustomerForm.vue -Encoding utf8
@'
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
    router.push(`/admin/customers/${data.id}`)
  }).finally(() => {
    customer.value.saving = false
  })
}
</script>
'@ | Set-Content -LiteralPath apps/web/src/pages/admin/customers/create.vue -Encoding utf8
@'
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
'@ | Set-Content -LiteralPath "apps/web/src/pages/admin/customers/[id].vue" -Encoding utf8
clear
@'
import { api } from "@/boot/axios"

export const getCustomers = (params = {}) => {
  return api.get('/customers', { params }).then(({ data }) => data)
}

export const createCustomer = (params = {}) => {
  return api.post('/customers', params).then(({ data }) => data)
}

export const getCustomer = (id) => {
  return api.get(`/customers/${id}`).then(({ data }) => data)
}

export const updateCustomer = (id, params = {}) => {
  return api.put(`/customers/${id}`, params).then(({ data }) => data)
}

export const deleteCustomer = (id) => {
  return api.delete(`/customers/${id}`).then(({ data }) => data)
}
'@ | Set-Content -LiteralPath apps/web/src/pages/admin/customers/_api.js -Encoding utf8
@'
<template>
  <q-form class="q-gutter-y-md">
    <q-input
      outlined
      stack-label
      required
      label="Nome"
      v-model="customer.name"
    />
    <q-input
      outlined
      stack-label
      required
      type="email"
      label="E-mail"
      v-model="customer.email"
    />
    <q-input
      outlined
      stack-label
      label="Telefone"
      v-model="customer.phone"
    />
    <q-input
      outlined
      stack-label
      type="date"
      label="Data de nascimento"
      v-model="customer.birth_date"
    />
    <div class="full-width bg-grey-1 q-py-md">
      <q-btn-group spread flat>
        <q-btn
          flat
          no-caps
          :loading="customer.saving"
          type="submit"
          label="Salvar"
          icon="save"
          color="positive"
        />
      </q-btn-group>
    </div>
  </q-form>
</template>

<script setup>
const customer = defineModel({
  default: () => ({
    id: null,
    name: null,
    email: null,
    phone: null,
    birth_date: null,
    saving: false,
  }),
})
</script>
'@ | Set-Content -LiteralPath apps/web/src/components/CustomerForm.vue -Encoding utf8
@'
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
    router.push(`/admin/customers/${data.id}`)
  }).finally(() => {
    customer.value.saving = false
  })
}
</script>
'@ | Set-Content -LiteralPath apps/web/src/pages/admin/customers/create.vue -Encoding utf8
@'
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
'@ | Set-Content -LiteralPath "apps/web/src/pages/admin/customers/[id].vue" -Encoding utf8
exit
