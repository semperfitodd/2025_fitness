import React, { useEffect, useState } from 'react';
import { fetchFitnessData } from '../utils/api';
import ProgressBarGraph from '../components/ProgressBarGraph';
import PieChart from '../components/PieChart';
import { getDefaultDate } from '../utils/dateUtils';
import { toTitleCase } from '../utils/stringUtils';

const Home = ({ user }) => {
    const [totalLifted, setTotalLifted] = useState(0);
    const [exerciseData, setExerciseData] = useState({});

    useEffect(() => {
        const loadData = async () => {
            if (!user) return;

            const result = await fetchFitnessData(user.email);
            if (!result) {
                console.error("Failed to load data from the API.");
                return;
            }

            setTotalLifted(result.total_lifted || 0);

            const exercises = {};
            for (const [exerciseName, data] of Object.entries(result.exercise_data || {})) {
                exercises[toTitleCase(exerciseName)] = data.total_volume;
            }
            setExerciseData(exercises);
        };

        loadData();
    }, [user]);

    const currentDate = new Date(getDefaultDate());
    const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
    const daysIntoYear = Math.ceil((currentDate - startOfYear) / (1000 * 60 * 60 * 24));

    return (
        <div>
            <h2 className="progress-title">Progress Overview</h2>
            <div className="chart-container-wrapper">
                <div className="chart-item">
                    <ProgressBarGraph totalLifted={totalLifted} daysIntoYear={daysIntoYear} />
                </div>
                <div className="chart-item">
                    <PieChart exercises={exerciseData} />
                </div>
            </div>
        </div>
    );
};

export default Home;
