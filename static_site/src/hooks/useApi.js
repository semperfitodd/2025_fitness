import { useState, useCallback } from 'react';
import { fetchFitnessData, fetchWorkoutPlan } from '../utils/api';

export const useApi = () => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const executeApiCall = useCallback(async (apiFunction, ...args) => {
        setLoading(true);
        setError(null);
        
        try {
            const result = await apiFunction(...args);
            return result;
        } catch (err) {
            const errorMessage = err.response?.data?.message || err.message || 'An error occurred';
            setError(errorMessage);
            console.error('API Error:', err);
            return null;
        } finally {
            setLoading(false);
        }
    }, []);

    const getFitnessData = useCallback(async (userEmail) => {
        return executeApiCall(fetchFitnessData, userEmail);
    }, [executeApiCall]);

    const getWorkoutPlan = useCallback(async () => {
        return executeApiCall(fetchWorkoutPlan);
    }, [executeApiCall]);

    return {
        loading,
        error,
        getFitnessData,
        getWorkoutPlan,
        clearError: () => setError(null)
    };
};
