import React from "react";
import { useNavigate } from 'react-router-dom';

const Options = () => {
    const navigate = useNavigate();

    const redirectTo = (path) => {
        navigate(path);
    };

    return (
        <div className="options-container">
            <h1>Choose an Option</h1>
            <button onClick={() => redirectTo("/restaurants")}>Restaurants</button>
            <button onClick={() => redirectTo("/outdoor-activities")}>Nearby Outdoor Activities</button>
            <button onClick={() => redirectTo("/events")}>Nearby Events</button>
            <button onClick={() => redirectTo("/finalize")}>Finalize</button>
        </div>
    );
};

export default Options;
