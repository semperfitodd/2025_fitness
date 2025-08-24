import React, { useState } from 'react';
import ErrorDisplay from '../components/ErrorDisplay';
import { useApi } from '../hooks/useApi';

const GenerateWorkoutScreen = () => {
    const [workoutPlan, setWorkoutPlan] = useState(null);
    const { loading, error, getWorkoutPlan, clearError } = useApi();

    const handleGenerateWorkout = async () => {
        const plan = await getWorkoutPlan();
        if (plan) {
            setWorkoutPlan(plan);
        }
    };

    const parseWorkoutPlan = (text) => {
        const sections = {
            Warmup: [],
            MainWorkout: [],
            Cooldown: [],
            TotalVolumeEstimation: [],
            Notes: []
        };
        let currentSection = null;

        text.split('\n').forEach((line) => {
            if (/Warmup/i.test(line)) {
                currentSection = 'Warmup';
            } else if (/Main Workout/i.test(line)) {
                currentSection = 'MainWorkout';
            } else if (/Cooldown/i.test(line)) {
                currentSection = 'Cooldown';
            } else if (/Total Volume Estimation/i.test(line)) {
                currentSection = 'TotalVolumeEstimation';
            } else if (/Notes/i.test(line)) {
                currentSection = 'Notes';
            } else if (currentSection && line.trim()) {
                sections[currentSection].push(line.trim().replace(/^\d+\.\s*/, '')); // Remove numbers
            }
        });

        return sections;
    };

    return (
        <div className="generate-workout-container fade-in">
            <h2>Generate a Workout Plan</h2>
            <ErrorDisplay error={error} onRetry={handleGenerateWorkout} onDismiss={clearError} />
            <button onClick={handleGenerateWorkout} className="generate-button" disabled={loading}>
                {loading ? 'Generating...' : 'Generate Workout'}
            </button>
            {workoutPlan && (
                <div className="workout-plan">
                    <h3>Workout Plan</h3>
                    {workoutPlan.map((item, index) => {
                        const sections = parseWorkoutPlan(item.text);
                        return (
                            <div key={index} className="workout-item">
                                {sections.Warmup.length > 0 && (
                                    <section>
                                        <h4>Warmup</h4>
                                        <div>
                                            {sections.Warmup.map((warmup, idx) => (
                                                <p key={idx}>{warmup}</p>
                                            ))}
                                        </div>
                                    </section>
                                )}
                                {sections.MainWorkout.length > 0 && (
                                    <section>
                                        <h4>Main Workout</h4>
                                        <div>
                                            {sections.MainWorkout.map((main, idx) => (
                                                <p key={idx}>{main}</p>
                                            ))}
                                        </div>
                                    </section>
                                )}
                                {sections.Cooldown.length > 0 && (
                                    <section>
                                        <h4>Cooldown</h4>
                                        <div>
                                            {sections.Cooldown.map((cooldown, idx) => (
                                                <p key={idx}>{cooldown}</p>
                                            ))}
                                        </div>
                                    </section>
                                )}
                                {sections.TotalVolumeEstimation.length > 0 && (
                                    <section>
                                        <h4>Total Volume Estimation</h4>
                                        <div>
                                            {sections.TotalVolumeEstimation.map((volume, idx) => (
                                                <p key={idx}>{volume}</p>
                                            ))}
                                        </div>
                                    </section>
                                )}
                                {sections.Notes.length > 0 && (
                                    <section>
                                        <h4>Notes</h4>
                                        <div>
                                            {sections.Notes.map((note, idx) => (
                                                <p key={idx}>{note}</p>
                                            ))}
                                        </div>
                                    </section>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
};

export default GenerateWorkoutScreen;
