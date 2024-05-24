import React, { useState, useEffect } from 'react';
import './ChatPage.css';

const handleCheckboxChange = async (restaurant, isChecked) => {
    // Prepare the data to be sent to the server
    const payload = { restaurant, isSelected: isChecked };

    // Send the data to the server
    const response = await fetch('http://127.0.0.1:5000/select-restaurant', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
    });

    const data = await response.json();
    console.log("Server response on selection:", data);
};

const RestaurantCard = ({ restaurant }) => {
    return (
        <div className="restaurant-card">
            <img src={restaurant.Image} alt={restaurant.Name} />
            <h3>{restaurant.Name}</h3>
            <p>{`Rating: ${restaurant.Rating}`}</p>
            <p>{`${restaurant.Location}, ${restaurant.City}, ${restaurant.State}, ${restaurant.Zip}`}</p>
            <p>{`Phone: ${restaurant.Phone}`}</p>
            <input 
                type="checkbox" 
                onChange={(e) => handleCheckboxChange(restaurant, e.target.checked)}
            />
        </div>
    );
};

const Restaurants = () => {
    const [chatHistory, setChatHistory] = useState([]);
    const [userInput, setUserInput] = useState('');

    useEffect(() => {
        const fetchChatHistory = async () => {
            const response = await fetch('http://127.0.0.1:5000/get-chat-history?origin=Restaurant');
            const data = await response.json();
            console.log(response);
            console.log(data);
            setChatHistory(data);
        };

        fetchChatHistory();
    }, []);

    const handleSend = async () => {
        if (!userInput.trim()) return;

        const newMessage = { type: 'type1', text: userInput, sender: 'user' };
        setChatHistory(prevHistory => [...prevHistory, newMessage]);

        const serverResponse = await sendMessageToServer(userInput);
        setChatHistory(prevHistory => [...prevHistory, serverResponse]);
        setUserInput('');
    };

    const sendMessageToServer = async (message) => {
        try{
            const latitude = sessionStorage.getItem('latitude');
            const longitude = sessionStorage.getItem('longitude');

            const response = await fetch('http://127.0.0.1:5000/process-message', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ message, origin:'Restaurant', latitude: latitude, longitude: longitude}),
            });

            const data = await response.json();
            if (data.restaurants) {
                const restaurantCards = data.restaurants.map(restaurant => ({ type: 'restaurant', data: restaurant }));
                setChatHistory(prevHistory => [...prevHistory, ...restaurantCards]);
                return restaurantCards;
            }

            return [{ type: 'type1', text: "Restaurants loaded", sender: 'server' }];
            
        } catch(error){
            console.error("Error:", error);
            return { text: "Error in communication with server", sender: 'server' };
        }
    };

    return (
        <div className="chat-container">
            <div className="messages">
                {chatHistory.map((item, index) => {
                    if (item.type === 'type1') {
                        return (
                            <div key={index} className={`message ${item.sender}`}>
                                {item.text}
                            </div>
                        );
                    } else if (item.type === 'restaurant') {
                        return <RestaurantCard key={index} restaurant={item.data} />;
                    }
                    return null;
                })}
            </div>
            <input
                type="text"
                value={userInput}
                onChange={(e) => setUserInput(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            />
            <button onClick={handleSend}>Send</button>
        </div>
    );
};

export default Restaurants;