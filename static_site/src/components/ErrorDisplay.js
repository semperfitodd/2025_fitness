import React from 'react';

const ErrorDisplay = ({ error, onRetry, onDismiss }) => {
    if (!error) return null;

    return (
        <div className="error-display">
            <div className="error-content">
                <h3>Error</h3>
                <p>{error}</p>
                <div className="error-actions">
                    {onRetry && (
                        <button onClick={onRetry} className="retry-button">
                            Try Again
                        </button>
                    )}
                    {onDismiss && (
                        <button onClick={onDismiss} className="dismiss-button">
                            Dismiss
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ErrorDisplay;
