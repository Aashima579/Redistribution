import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Data
data = {
    'Scenario': ['Scenario 1', 'Scenario 2', 'Scenario 3'],
    'T1': [12, 5, 15],
    'T2': [15, 20, 10],
    'T3': [70, 50, 40]
}

df = pd.DataFrame(data)

# Create two separate dataframes: one for T1 and T2, another for T3
heatmap_data_t1_t2 = df[['Scenario', 'T1', 'T2']].set_index('Scenario').T
heatmap_data_t3 = df[['Scenario', 'T3']].set_index('Scenario').T

# Plotting the heatmap for T1 and T2
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 12), gridspec_kw={'height_ratios': [2, 1]})

sns.heatmap(heatmap_data_t1_t2, annot=True, cmap=sns.color_palette("YlGnBu", as_cmap=True), cbar_kws={'label': 'Transition Rate (%)'}, ax=ax1)
ax1.set_title('Heatmap of Transition Rates for T1 and T2 by Scenario')
ax1.set_xlabel('')
ax1.set_ylabel('Individual Type')

# Plotting the heatmap for T3
sns.heatmap(heatmap_data_t3, annot=True, cmap=sns.color_palette("coolwarm", as_cmap=True), cbar_kws={'label': 'Transition Rate (%)'}, ax=ax2)
ax2.set_title('Heatmap of Transition Rates for T3 by Scenario')
ax2.set_xlabel('Scenario')
ax2.set_ylabel('Individual Type')

plt.tight_layout()
plt.show()
