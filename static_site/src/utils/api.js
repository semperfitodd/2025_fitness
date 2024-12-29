import axios from "axios";

export const fetchFitnessData = async () => {
    const API_KEY = process.env.REACT_APP_API_KEY;

    try {
        const response = await axios.get("/get", {
            headers: {
                "x-api-key": API_KEY,
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching fitness data:", error);
        return [];
    }
};
