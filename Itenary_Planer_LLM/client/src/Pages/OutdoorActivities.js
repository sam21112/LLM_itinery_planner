import React, { useState, useEffect } from 'react';
import './ChatPage.css';

const handleCheckboxChange = async (activity, isChecked) => {
    // Prepare the data to be sent to the server
    const payload = { activity, isSelected: isChecked };

    // Send the data to the server
    const response = await fetch('http://127.0.0.1:5000//select-activity', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
    });

    const data = await response.json();
    console.log("Server response on selection:", data);
};

const ActivityCard = ({ activity }) => {
    return (
        <div className="restaurant-card">
            {activity.Image && <img src={activity.Image} alt={activity.Name} />}
            <h3>{activity.Name}</h3> 
            <p>{`Rating: ${activity.Rating}`}</p>
            <p>{`User Reviews: ${activity.Total_Rating}`}</p>
            <p>{`${activity.Location}`}</p>
            <input 
                type="checkbox" 
                onChange={(e) => handleCheckboxChange(activity, e.target.checked)}
            />
        </div>
    );
};


const Activities = () => {
    const [chatHistory, setChatHistory] = useState([]);
    const [userInput, setUserInput] = useState('');
    const [, forceRerender] = useState();

    useEffect(() => {
        const fetchChatHistory = async () => {
            const response = await fetch('http://127.0.0.1:5000/get-chat-history?origin=Outdoor');
            const data = await response.json();
            console.log(response);
            console.log(data);
            setChatHistory(data);
        };

        fetchChatHistory();
    }, []);

    const triggerRerender = () => forceRerender({});

    const handleSend = async () => {
        if (!userInput.trim()) return;

        const newMessage = { type: 'type2', text: userInput, sender: 'user' };
        setChatHistory(prevHistory => [...prevHistory, newMessage]);

        // Optimistically add a loading message
        const loadingMessage = { type: 'type2', text: "Processing...", sender: 'server' };
        setChatHistory(prevHistory => [...prevHistory, loadingMessage]);

        const serverResponse = await sendMessageToServer(userInput);
        // console.log("Send Message to Server Response:", serverResponse);
        setChatHistory(prevHistory => {
            // Filter out the loading message
            const updatedHistory = prevHistory.filter(msg => msg.text !== "Processing...");
            const newHistory = Array.isArray(serverResponse) ? [...updatedHistory, ...serverResponse] : [...updatedHistory, serverResponse];
            // console.log("New chat history:", newHistory);
            setUserInput('');
            return newHistory;
        });

        triggerRerender();
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
                body: JSON.stringify({ message, origin:'Outdoor', latitude: latitude, longitude: longitude}),
            });

            const data = await response.json();
            // console.log("Server Response:", data);
            if (data.outdoor) {
                const activityCards = data.outdoor.map(activity => ({ type: 'outdoor', data: activity }));
                setChatHistory(prevHistory => [...prevHistory, ...activityCards]);
                return activityCards;
            }

            return [{ type: 'type2', text: "Activities loaded", sender: 'server' }];
            
        } catch(error){
            console.error("Error:", error);
            return { text: "Error in communication with server", sender: 'server' };
        }
    };

    return (
        <div className="chat-container">
            <div className="messages">
                {chatHistory.map((item, index) => {
                    if (item.type === 'type2') {
                        return (
                            <div key={index} className={`message ${item.sender}`}>
                                {item.text}
                            </div>
                        );
                    } else if (item.type === 'outdoor') {
                        return <ActivityCard key={index} activity={item.data} />;
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

export default Activities;