import React, { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './lib/AuthContext'
import { ToastProvider } from './lib/ToastContext'
import Layout from './components/layout/Layout'

const AuthPage = lazy(() => import('./components/auth/AuthPage'))
const Onboarding = lazy(() => import('./components/auth/Onboarding'))
const Dashboard = lazy(() => import('./components/dashboard/Dashboard'))
const Nutrition = lazy(() => import('./components/nutrition/Nutrition'))
const Sleep = lazy(() => import('./components/sleep/Sleep'))
const Workout = lazy(() => import('./components/workout/Workout'))
const Goals = lazy(() => import('./components/goals/Goals'))
const WeeklyLog = lazy(() => import('./components/workout/WeeklyLog'))
const Game = lazy(() => import('./components/game/Game'))
const Profile = lazy(() => import('./components/profile/Profile'))

function LoadingSpinner() {
  return <div style={{display:'flex',alignItems:'center',justifyContent:'center',height:'100vh',background:'var(--bg)'}}><div style={{width:40,height:40,border:'3px solid var(--border)',borderTopColor:'var(--green)',borderRadius:'50%',animation:'spin 0.8s linear infinite'}} /></div>
}

function ProtectedRoute({ children }) {
  const { user, loading, profile } = useAuth()
  if (loading) return <LoadingSpinner />
  if (!user) return <Navigate to="/auth" replace />
  if (user && profile && !profile.age) return <Navigate to="/onboarding" replace />
  return children
}

function AuthRoute({ children }) {
  const { user, loading } = useAuth()
  if (loading) return <LoadingSpinner />
  if (user) return <Navigate to="/dashboard" replace />
  return children
}

function AppRoutes() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/auth" element={<AuthRoute><AuthPage /></AuthRoute>} />
        <Route path="/onboarding" element={<Onboarding />} />
        <Route path="/dashboard" element={<ProtectedRoute><Layout><Dashboard /></Layout></ProtectedRoute>} />
        <Route path="/nutrition" element={<ProtectedRoute><Layout><Nutrition /></Layout></ProtectedRoute>} />
        <Route path="/sleep" element={<ProtectedRoute><Layout><Sleep /></Layout></ProtectedRoute>} />
        <Route path="/workout" element={<ProtectedRoute><Layout><Workout /></Layout></ProtectedRoute>} />
        <Route path="/weekly" element={<ProtectedRoute><Layout><WeeklyLog /></Layout></ProtectedRoute>} />
        <Route path="/goals" element={<ProtectedRoute><Layout><Goals /></Layout></ProtectedRoute>} />
        <Route path="/game" element={<ProtectedRoute><Layout><Game /></Layout></ProtectedRoute>} />
        <Route path="/profile" element={<ProtectedRoute><Layout><Profile /></Layout></ProtectedRoute>} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </Suspense>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <AppRoutes />
      </ToastProvider>
    </AuthProvider>
  )
}
