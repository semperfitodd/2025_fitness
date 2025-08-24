import React, { useEffect, useState } from 'react';
import ProgressBarGraph from '../components/ProgressBarGraph';
import PieChart from '../components/PieChart';
import Loading from '../components/Loading';
import ErrorDisplay from '../components/ErrorDisplay';
import { useApi } from '../hooks/useApi';
import { toTitleCase } from '../utils/stringUtils';

const Home = ({ user }) => {
    const [totalLifted, setTotalLifted] = useState(0);
    const [exerciseData, setExerciseData] = useState({});
    const { loading, error, getFitnessData, clearError } = useApi();

    useEffect(() => {
        const loadData = async () => {
            if (!user) return;

            const result = await getFitnessData(user.email);
            if (!result) return;

            setTotalLifted(result.total_lifted || 0);

            const exercises = {};
            for (const [exerciseName, data] of Object.entries(result.exercise_data || {})) {
                exercises[toTitleCase(exerciseName)] = data.total_volume;
            }
            setExerciseData(exercises);
        };

        loadData();
    }, [user, getFitnessData]);

    if (loading) {
        return <Loading message="Loading your fitness data..." />;
    }

    return (
        <div className="fade-in">
            <ErrorDisplay error={error} onRetry={() => window.location.reload()} onDismiss={clearError} />
            <h2 className="progress-title">Progress Overview</h2>
            <div className="chart-container-wrapper">
                <div className="chart-item slide-up">
                    <ProgressBarGraph totalLifted={totalLifted} />
                </div>
                <div className="chart-item slide-up">
                    <PieChart exercises={exerciseData} />
                </div>
            </div>
        </div>
    );
};

export default Home;
