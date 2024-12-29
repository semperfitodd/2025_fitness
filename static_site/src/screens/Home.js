import React, {useEffect, useState} from 'react';
import {fetchFitnessData} from '../utils/api';
import ProgressBarGraph from '../components/ProgressBarGraph';
import PieChart from '../components/PieChart';
import {getDefaultDate} from '../utils/dateUtils';
import {toTitleCase} from '../utils/stringUtils';

const Home = () => {
    const [totalLifted, setTotalLifted] = useState(0);
    const [exerciseData, setExerciseData] = useState({});

    useEffect(() => {
        const loadData = async () => {
            const result = await fetchFitnessData();

            const totalLiftedData = result.find(
                (exercise) => exercise.exercise_name === 'total_lifted'
            );
            setTotalLifted(totalLiftedData?.total_volume || 0);

            const exercises = {};
            result.forEach((entry) => {
                if (entry.exercise_name !== 'total_lifted' && entry.total_volume) {
                    const titleCasedName = toTitleCase(entry.exercise_name);
                    exercises[titleCasedName] = entry.total_volume;
                }
            });
            setExerciseData(exercises);
        };

        loadData();
    }, []);

    const currentDate = new Date(getDefaultDate());
    const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
    const daysIntoYear = Math.ceil((currentDate - startOfYear) / (1000 * 60 * 60 * 24));

    return (
        <div>
            <h2 className="progress-title">Progress Overview</h2>
            <div className="chart-container-wrapper">
                <div className="chart-item">
                    <ProgressBarGraph totalLifted={totalLifted} daysIntoYear={daysIntoYear}/>
                </div>
                <div className="chart-item">
                    <PieChart exercises={exerciseData}/>
                </div>
            </div>
        </div>
    );
};

export default Home;
