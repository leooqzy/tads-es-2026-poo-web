import { defineBoot } from '#q-app';
import axios from 'axios'
import { LocalStorage, Notify } from 'quasar'

const getToken = () => {
  const auth = LocalStorage.getItem('auth_data')
  return auth?.token ?? null;
}

const api = axios.create({ baseURL: import.meta.env.QCLI_API_URL })

api.interceptors.request.use((config) => {
  const token = getToken()
  if (token && token.length > 10) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
}, (error) => Promise.reject(error));

api.interceptors.response.use((response) => response, (error) => {
  const code = error?.response?.data?.code
    ?? error?.response?.status
    ?? error?.code
    ?? {}

  if (code == 401) {
    window.location.href = '/#/login'
    return Promise.reject(error)
  }

  if (code) {
    Notify.create({
      message: code,
      type: 'negative',
    })
  }

  return Promise.reject(error)
})

export default defineBoot(({ app }) => {
  app.config.globalProperties.$axios = axios
  app.config.globalProperties.$api = api
})

export { api }