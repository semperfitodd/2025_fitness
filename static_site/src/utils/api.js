import axios from 'axios';
import { API_ENDPOINTS } from './constants';
import { logError, logUserAction } from './errorTracking';

const getApiHeaders = (userEmail = null) => {
    const headers = {
        'x-api-key': process.env.REACT_APP_API_KEY,
        'Content-Type': 'application/json',
    };
    
    if (userEmail) {
        headers['x-user-email'] = userEmail;
    }
    
    return headers;
};

export const fetchFitnessData = async (userEmail) => {
    try {
        logUserAction('fetch_fitness_data', { userEmail });
        console.log("Sending userEmail:", userEmail);
        
        const response = await axios.post(
            API_ENDPOINTS.GET,
            { user: userEmail },
            { headers: getApiHeaders(userEmail) }
        );
        console.log("Response from API:", response.data);
        return response.data;
    } catch (error) {
        logError(error, { 
            action: 'fetch_fitness_data', 
            userEmail 
        });
        console.error("Error fetching fitness data:", error.response?.data || error.message);
        throw error;
    }
};

export const fetchWorkoutPlan = async () => {
    try {
        logUserAction('fetch_workout_plan');
        
        const response = await axios.get(API_ENDPOINTS.WORKOUT, {
            headers: getApiHeaders(),
        });
        return response.data.workout_plan;
    } catch (error) {
        logError(error, { 
            action: 'fetch_workout_plan' 
        });
        console.error('Error fetching workout plan:', error.response?.data || error.message);
        throw error;
    }
};
