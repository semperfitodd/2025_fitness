import React from 'react';

const Header = ({ user, onSignOut, onNavigate }) => {
  return (
    <header>
      <h1>Fitness App</h1>
      {user ? (
        <div>
          <p>Welcome, {user.email}</p>
          <button onClick={() => onNavigate('home')}>Home</button>
          <button onClick={() => onNavigate('insert')}>Insert</button>
          <button onClick={onSignOut}>Sign out</button>
        </div>
      ) : (
        <p>Please sign in to access the app.</p>
      )}
    </header>
  );
};

export default Header;
