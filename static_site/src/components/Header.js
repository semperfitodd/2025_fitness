import React from 'react';

const Header = ({ user, onSignOut, onNavigate }) => {
  return (
    <header>
      <h1>Todd Bernson's 2025 Fitness Goals Dashboard</h1>
      <h2>{new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</h2>
      {user ? (
        <div>
          <p>Welcome, {user.email}</p>
          <div>
            <button onClick={() => onNavigate('home')}>Home</button>
            <button onClick={() => onNavigate('insert')}>Insert</button>
            <button onClick={onSignOut}>Sign out</button>
          </div>
        </div>
      ) : null}
    </header>
  );
};

export default Header;
