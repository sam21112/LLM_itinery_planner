import React, { useState, useEffect } from 'react';
import './Finalize.css';

const RestaurantCard = ({ restaurant }) => {
    return (
        <div className="card">
            <img src={restaurant.Image} alt={restaurant.Name} />
            <h3>{restaurant.Name}</h3>
            <p>{`Rating: ${restaurant.Rating}`}</p>
            <p>{`${restaurant.Location}, ${restaurant.City}, ${restaurant.State}, ${restaurant.Zip}`}</p>
            <p>{`Phone: ${restaurant.Phone}`}</p>
        </div>
    );
};

const ActivityCard = ({ activity }) => {
    return (
        <div className="card">
            {activity.Image && <img src={activity.Image} alt={activity.Name} />}
            <h3>{activity.Name}</h3> 
            <p>{`Rating: ${activity.Rating}`}</p>
            <p>{`User Reviews: ${activity.Total_Rating}`}</p>
            <p>{`${activity.Location}`}</p>
        </div>
    );
};

const Finalize = () => {
    const [selectedRestaurants, setSelectedRestaurants] = useState([]);
    const [selectedActivities, setSelectedActivities] = useState([]);

    // Retrieve trip details from session storage
    const endDate = sessionStorage.getItem('endDate');
    const startDate = sessionStorage.getItem('startDate');
    const needHotel = sessionStorage.getItem('needHotel') === 'true';
    const needFlight = sessionStorage.getItem('needFlight') === 'true';

    // Calculate duration of stay
    const diffInMs = new Date(endDate).getTime() - new Date(startDate).getTime()
    const diffInDays = diffInMs / (1000 * 60 * 60 * 24);
    const duration = diffInDays >= 0 ? `${diffInDays} days` : 'Invalid date range';

    const latitude = sessionStorage.getItem('latitude');
    const longitude = sessionStorage.getItem('longitude');
    useEffect(() => {
        fetch('http://127.0.0.1:5000/get-selected')
            .then(response => response.json())
            .then(data => {
                // Assuming each item in data has a 'type' of 'restaurant' or 'activity'
                setSelectedRestaurants(data.filter(item => item.type === 'restaurant'));
                setSelectedActivities(data.filter(item => item.type === 'activity'));
            })
            .catch(error => console.error('Error fetching selected items:', error));
    }, []);

    return (
        <div>
            <div className="trip-container">
                <h1>Trip Details:</h1>
                <p><b>Latitude:</b> {latitude}</p>
                <p><b>Longitude:</b> {longitude}</p>
                <p><b>Start Date:</b> {startDate ? new Date(startDate).toLocaleDateString() : 'N/A'}</p>
                <p><b>End Date:</b> {endDate ? new Date(endDate).toLocaleDateString() : 'N/A'}</p>
                <p><b>Duration of Stay:</b> {duration}</p>
                <p><b>Need Hotel:</b> {needHotel ? 'Yes' : 'No'}</p>
                <p><b>Need Flight:</b> {needFlight ? 'Yes' : 'No'}</p>
            </div>
            <div className="finalize-container">
                <h2>Selected Restaurants:</h2>
                <div className="cards-container">
                    {selectedRestaurants.map((restaurant, index) => (
                        <div key={index}>
                            <RestaurantCard key={index} restaurant={restaurant} />
                        </div>
                    ))}
                </div>
            </div>
            <div className="finalize-container">
                <h2>Selected Places:</h2>
                <div className="cards-container">
                    {selectedActivities.map((activity, index) => (
                        <div key={index}>
                            <ActivityCard key={index} activity={activity} />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default Finalize;
