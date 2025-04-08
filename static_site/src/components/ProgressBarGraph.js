import React from 'react';
import { BarElement, CategoryScale, Chart as ChartJS, Legend, LinearScale, Title, Tooltip } from 'chart.js';
import { Bar } from 'react-chartjs-2';
import { chartOptions } from '../utils/chartConfig';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const ProgressBarGraph = ({ totalLifted }) => {
    // Calculate the current date and days into the year
    const currentDate = new Date();
    const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
    const daysIntoYear = Math.floor((currentDate - startOfYear) / (1000 * 60 * 60 * 24)) + 1; // Count the current day

    // Calculate percentages
    const totalLiftedPercentage = Math.round((totalLifted / 25000000) * 100 * 100) / 100; // Rounded to 2 decimals
    const daysIntoYearPercentage = Math.round((daysIntoYear / 365) * 100 * 100) / 100; // Rounded to 2 decimals

    // Log values for debugging
    console.log("Days Into Year:", daysIntoYear);
    console.log("Days Into Year Percentage:", daysIntoYearPercentage);

    // Data object passed to the chart
    const data = {
        labels: ['Total Lifted', 'Days Into Year'],
        datasets: [
            {
                label: 'Progress (%)',
                data: [totalLiftedPercentage, daysIntoYearPercentage],
                backgroundColor: ['#FFFF00', '#FF0000'],
                borderColor: ['#B2B200', '#B20000'],
                borderWidth: 1,
            },
        ],
    };

    console.log("Chart Data:", data);

    // Updated chart options with improved visibility for small values
    const updatedChartOptions = {
        ...chartOptions,
        scales: {
            x: {
                min: 0,
                max: 100,
            },
        },
        plugins: {
            ...chartOptions.plugins,
            tooltip: {
                callbacks: {
                    label: (context) => {
                        const value = context.raw.toFixed(2);
                        if (context.label === 'Days Into Year') {
                            return `${context.label}: ${value}% of the year completed (${daysIntoYear} days)`;
                        }
                        if (context.label === 'Total Lifted') {
                            return `${context.label}: ${value}% of goal lifted (${totalLifted.toLocaleString()} lbs)`;
                        }
                        return `${context.label}: ${value}%`;
                    },
                },
            },
        },
        indexAxis: 'y',
    };

    return (
        <div className="chart-container">
            <Bar data={data} options={updatedChartOptions} />
        </div>
    );
};

export default ProgressBarGraph;
