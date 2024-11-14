import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load the data
df = pd.read_csv('speedtest_results.csv')

# Convert 'Timestamp' to datetime
df['Timestamp'] = pd.to_datetime(df['Timestamp'])

# Set 'Timestamp' as the index for time-series operations
df.set_index('Timestamp', inplace=True)

# 1. Basic Data Inspection
print("Data Overview:")
print(df.head())
print("\nData Info:")
print(df.info())
print("\nSummary Statistics:")
print(df.describe())

# 2. Missing Values Check
print("\nMissing Values:")
print(df.isnull().sum())

# 3. Visualize Download and Upload Speeds Over Time
plt.figure(figsize=(14, 6))
plt.plot(df.index, df['Download'], label='Download Speed (Mbps)', color='blue')
plt.plot(df.index, df['Upload'], label='Upload Speed (Mbps)', color='orange')
plt.xlabel('Time')
plt.ylabel('Speed (Mbps)')
plt.title('Internet Download and Upload Speeds Over Time')
plt.legend()
plt.show()

# 4. Distribution of Download and Upload Speeds
plt.figure(figsize=(12, 5))
sns.histplot(df['Download'], kde=True, color='blue', label='Download Speed')
sns.histplot(df['Upload'], kde=True, color='orange', label='Upload Speed')
plt.xlabel('Speed (Mbps)')
plt.title('Distribution of Download and Upload Speeds')
plt.legend()
plt.show()

# 5. Box Plot for Identifying Outliers
plt.figure(figsize=(10, 5))
sns.boxplot(data=df[['Download', 'Upload']])
plt.title('Box Plot of Download and Upload Speeds')
plt.ylabel('Speed (Mbps)')
plt.show()

# 6. Hourly Aggregation and Visualization (if more than one day of data is available)
df['Hour'] = df.index.hour  # Extract hour from timestamp
hourly_avg = df.groupby('Hour').mean()  # Group by hour and calculate average

plt.figure(figsize=(12, 6))
plt.plot(hourly_avg.index, hourly_avg['Download'], label='Average Download Speed (Mbps)', color='blue')
plt.plot(hourly_avg.index, hourly_avg['Upload'], label='Average Upload Speed (Mbps)', color='orange')
plt.xlabel('Hour of Day')
plt.ylabel('Average Speed (Mbps)')
plt.title('Average Internet Speeds by Hour of Day')
plt.legend()
plt.show()

# 7. Resample and Aggregate Data by Day to observe Daily Trends (if data spans multiple days)
# daily_avg = df.resample('D').mean()

# If data has more than one day, we could uncomment and plot as follows:
# plt.figure(figsize=(12, 6))
# plt.plot(daily_avg.index, daily_avg['Download'], label='Daily Average Download Speed (Mbps)', color='blue')
# plt.plot(daily_avg.index, daily_avg['Upload'], label='Daily Average Upload Speed (Mbps)', color='orange')
# plt.xlabel('Date')
# plt.ylabel('Daily Average Speed (Mbps)')
# plt.title('Daily Average Internet Speeds')
# plt.legend()
# plt.show()

# 8. Correlation Between Download and Upload Speeds
plt.figure(figsize=(8, 6))
sns.heatmap(df[['Download', 'Upload']].corr(), annot=True, cmap='coolwarm')
plt.title('Correlation Between Download and Upload Speeds')
plt.show()

# 9. Anomaly Detection (optional: speeds below a threshold)
# Define a threshold (e.g., download speed < 50 Mbps or upload speed < 5 Mbps)
anomalies = df[(df['Download'] < 50) | (df['Upload'] < 5)]
print("\nAnomalies (Speeds below threshold):")
print(anomalies)

# Visualize anomalies over time if they exist
if not anomalies.empty:
    plt.figure(figsize=(14, 6))
    plt.plot(df.index, df['Download'], label='Download Speed (Mbps)', color='blue')
    plt.plot(df.index, df['Upload'], label='Upload Speed (Mbps)', color='orange')
    plt.scatter(anomalies.index, anomalies['Download'], color='red', label='Anomalies (Download)', zorder=5)
    plt.scatter(anomalies.index, anomalies['Upload'], color='purple', label='Anomalies (Upload)', zorder=5)
    plt.xlabel('Time')
    plt.ylabel('Speed (Mbps)')
    plt.title('Internet Speeds with Anomalies Highlighted')
    plt.legend()
    plt.show()
