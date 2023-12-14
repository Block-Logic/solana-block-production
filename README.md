# solana-block-production
A workspace to explore Solana validator block production and "skipped after" metrics.

I'm curious to see if some validators are slow to produce blocks and causing problems for the next leader in line. You can use this tool to quickly calculate the Skipped After metrics for a given epoch.

1. Create a JSON file with block production for a given epoch.
2. Run the script to process the JSON file and produce a CSV file.
3. Analyze the data in the CSV file with your tool of choice.

Example command to create a JSON file for epoch 545. Change "545" to your desired epoch.
`solana block-production --verbose --output json --epoch 545 > solana-block-production-545.json`

The script should work with any recent version of Ruby. Example:
`ruby solana-block-production.rb solana-block-production-545.json`

Look for the output in `solana-block-production-545.csv`. The column layout is `validator,leader_slots,blocks_produced,skipped_slots,skipped_after,skip_rate,skip_after_rate`

Links to a couple of CSV files for epochs 544 & 545:
544: https://blocklogicllc.box.com/s/jwdx87lp1faftumkpo77a7c5budvz0xv
545: https://blocklogicllc.box.com/s/sv080tpkl1ij42mqx3vp7x2wirfxfa26
