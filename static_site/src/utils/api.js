import axios from 'axios';

export const fetchFitnessData = async (userEmail) => {
    const API_KEY = process.env.REACT_APP_API_KEY;

    try {
        console.log("Sending userEmail:", userEmail); // Log the email being sent
        const response = await axios.post(
            "/get",
            { user: userEmail }, // Body
            {
                headers: {
                    "x-api-key": API_KEY,
                    "Content-Type": "application/json",
                },
            }
        );
        console.log("Response from API:", response.data); // Log response for debugging
        return response.data;
    } catch (error) {
        console.error("Error fetching fitness data:", error.response?.data || error.message);
        return null;
    }
};
