import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import './ChatPage.css';

const LandingPage = () => {
    const navigate = useNavigate();
    const [startDate, setStartDate] = useState(new Date());
    const [endDate, setEndDate] = useState(new Date());
    const [needHotel, setNeedHotel] = useState(false);
    const [needFlight, setNeedFlight] = useState(false);
    const [location, setLocation] = useState('');

    const setSessionStorageItems = (latitude, longitude) => {
        sessionStorage.setItem('latitude', latitude);
        sessionStorage.setItem('longitude', longitude);
        sessionStorage.setItem('startDate', startDate.toISOString());
        sessionStorage.setItem('endDate', endDate.toISOString());
        sessionStorage.setItem('needHotel', needHotel);
        sessionStorage.setItem('needFlight', needFlight);
    };

    const handleManualLocationInput = async () => {
        try {
            const response = await fetch('http://127.0.0.1:5000/process-location', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ location }),
            });
    
            const data = await response.json();
            if (data.latitude && data.longitude) {
                setSessionStorageItems(data.latitude, data.longitude);
                navigate("/Options");
            } else {
                console.error("Invalid location data received");
            }
        } catch (error) {
            console.error("Error in sending location to server:", error);
        }
    };
    
    const handleGeolocationPermission = () => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    console.log("Location Granted: ", position);
                    // You can also send this location to the server here if needed
                    setSessionStorageItems(position.coords.latitude, position.coords.longitude);
                    navigate("./Options"); // Redirect to Page-2 on success
                },
                (error) => {
                    console.error("Error Code = " + error.code + " - " + error.message);
                }
            );
        } else {
            alert("Geolocation is not supported by this browser.");
        }
    };

    return (
        <div className="chat-container-landing">
            <h1>Welcome to Our App</h1>
            <div className="container-landing">
                <label>Start Date: </label>
                <input 
                    type="date" 
                    value={startDate.toISOString().split('T')[0]}
                    onChange={(e) => setStartDate(new Date(e.target.value))}
                />
            </div>
            <div className="container-landing">
                <label>End Date: </label>
                <input 
                    type="date" 
                    value={endDate.toISOString().split('T')[0]}
                    onChange={(e) => setEndDate(new Date(e.target.value))}
                />
            </div>
            <div className="container-landing">
                <label>Need a hotel? </label>
                <input 
                    type="checkbox"
                    checked={needHotel}
                    onChange={(e) => setNeedHotel(e.target.checked)}
                />
            </div>
            <div className="container-landing">
                <label>Need flight tickets? </label>
                <input 
                    type="checkbox"
                    checked={needFlight}
                    onChange={(e) => setNeedFlight(e.target.checked)}
                />
            </div>
            <div className="container-landing">
                <label>Location (City, State): </label>
                <input 
                    type="text" 
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                />
            </div>
            <button onClick={handleGeolocationPermission}>Use Current Location and Continue</button>
            <button onClick={handleManualLocationInput}>Use Entered Location and Continue</button>
        </div>
    );
};

export default LandingPage;
