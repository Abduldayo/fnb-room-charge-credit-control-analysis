# F&B Room Charge & Credit Control Analysis

SQL and Power BI analysis of hotel F&B room charges, guest credit and checkout outcomes.

## Business Problem

This project was inspired by an issue I noticed in my current hotel role.

F&B staff use Bizzon to post charges to guest rooms, while Front Desk uses Opera to check guest credit. Before, F&B had to walk to Front Desk to confirm if a guest had enough credit before posting a room charge.

During busy periods, this check could sometimes be missed, especially with new staff or staff turnover.

## Project Objective

The aim was to analyse how much F&B spending happened where guests had no credit or insufficient available credit, and to see what happened to those balances at checkout.

The data used in this project is fully simulated to protect guest and company information.

## Tools

MySQL
Power BI

## Key Findings

Total F&B charges: £368,288
At-risk F&B charges: £246,184
Actual unpaid amount: £39,231.52
Actual disputed amount: £17,589.34
At-risk adverse checkout rate: 30.63%
Not-at-risk adverse checkout rate: 13.22%

## Recommendation

I recommended integrating the No Post control between Front Desk Opera and F&B Bizzon so that when F&B enters a room number, the guest's credit can be checked automatically.

If the guest has no credit or insufficient available credit, the room charge can be blocked instead of relying on staff to check manually.

## Business Impact

No Post was integrated due to my recommendation, helping protect hotel revenue by preventing room charges being posted where guests had no credit or insufficient available credit. It also reduced the need for manual credit checks at Front Desk, allowing F&B staff to spend more time serving guests instead of walking to reception to confirm credit.
