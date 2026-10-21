<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn flat dense round icon="menu" aria-label="Menu" @click="toggleLeftDrawer" />
        <q-toolbar-title> Quasar App </q-toolbar-title>
        <div>
          {{ user?.name }} <br>
          <small>{{ user?.email }}</small>
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered>
      <q-list>
        <q-item-label header> MENU </q-item-label>
        <EssentialLink v-for="link in linksList" :key="link.label" v-bind="link" />
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref } from 'vue'
import EssentialLink from '@/components/EssentialLink.vue'
import { LocalStorage } from 'quasar'

const linksList = [
  {
    label: 'Categorias',
    caption: 'categorias',
    icon: 'category',
    link: '/admin/categories',
  },
  {
    label: 'Produtos',
    caption: 'produtos',
    icon: 'category',
    link: '/admin/products',
  },
  {
    label: 'Sair',
    caption: 'sair do sistema',
    icon: 'exit_to_app',
    link: '/admin/logout',
  },
]

const leftDrawerOpen = ref(false)

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

const auth = LocalStorage.getItem('auth_data')
const user = auth?.user ?? null
</script>