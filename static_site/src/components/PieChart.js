import React from 'react';
import {ArcElement, Chart as ChartJS, Legend, Tooltip,} from 'chart.js';
import {Pie} from 'react-chartjs-2';
import {chartOptions, colorPalette} from '../utils/chartConfig';

ChartJS.register(ArcElement, Tooltip, Legend);

const PieChart = ({exercises}) => {
    const data = {
        labels: Object.keys(exercises),
        datasets: [
            {
                data: Object.values(exercises),
                backgroundColor: colorPalette.slice(0, Object.keys(exercises).length),
                borderWidth: 2,
                borderColor: '#1a1a2e',
                hoverBorderWidth: 4,
                hoverBorderColor: '#e94560',
                hoverOffset: 30,
                hoverRadius: 5,
            },
        ],
    };

    // Updated chart options with modern styling and no legend
    const updatedChartOptions = {
        ...chartOptions,
        plugins: {
            legend: {
                display: false // Remove legend
            },
            tooltip: {
                backgroundColor: '#16213e',
                titleColor: '#ffffff',
                bodyColor: '#b0b0b0',
                borderColor: '#e94560',
                borderWidth: 1,
                cornerRadius: 8,
                callbacks: {
                    label: (context) => {
                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                        const percentage = ((context.raw / total) * 100).toFixed(2);
                        return `${context.label}: ${context.raw.toLocaleString()} lbs (${percentage}%)`;
                    },
                },
            },
        },
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 1500,
            easing: 'easeOutQuart',
            animateRotate: true,
            animateScale: true,
        },
        transitions: {
            active: {
                animation: {
                    duration: 400,
                    easing: 'easeOutQuart'
                }
            }
        },

    };

    return (
        <div className="chart-container">
            <Pie data={data} options={updatedChartOptions}/>
        </div>
    );
};

export default PieChart;
