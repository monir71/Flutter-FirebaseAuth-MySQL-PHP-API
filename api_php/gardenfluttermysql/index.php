<?php
	session_start();
	require_once('db_config.php');
?>
<!DOCTYPE html>
<html>
<head>
	<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
	<style type="text/css">
		#menu_div {
			text-align:center;
		}
		#main {
			display:flex;
		}
		#left {
			width:20%;
		}
		#center {
			width:60%;
		}
		#right {
			width:20%;	
		}
		
		body {
            background: #f4f7fb;
            font-family: Arial, sans-serif;
        }

        .chart-container {
			width: 500px;
			display: inline-block;
			vertical-align: top;
			margin: 20px;
		}

        .chart-title {
            text-align: center;
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
        }

        canvas {
            max-height: 350px;
        }

        .summary {
            display: flex;
            justify-content: space-around;
            margin-top: 20px;
        }

        .box {
            text-align: center;
        }

        .box span {
            display: block;
            font-size: 18px;
            font-weight: bold;
        }

        .income { color: #2ecc71; }
        .expense { color: #e74c3c; }
        .funding { color: #3498db; }
	</style>
</head>
<body>
	<div id="menu_div">
		<h1 class="sub-head" style="font-size:3em;" >আমার বাগান - My Garden!</h1>	
	</div>
	
	<!-- Chart Area Start -->
	<?php
		$gardens = $conn->query("SELECT garden_id, garden_name FROM gardenindex");

		while($g = $gardens->fetch()) {

			$gid = $g['garden_id'];
			$gname = $g['garden_name'];

			// Get totals
			$income = $conn->query("SELECT IFNULL(SUM(income_amount),0) FROM income WHERE garden_id = $gid")->fetchColumn();
			$expense = $conn->query("SELECT IFNULL(SUM(exp_amount),0) FROM exp WHERE garden_id = $gid")->fetchColumn();
			$fund = $conn->query("SELECT IFNULL(SUM(fund_amount),0) FROM fund WHERE garden_id = $gid")->fetchColumn();
			$loan = $conn->query("SELECT IFNULL(SUM(loan_amount),0) FROM loan WHERE garden_id = $gid")->fetchColumn();
	?>
	
	<div class="chart-container">
		<div class="chart-title"><?php echo $gname; ?><br><span style="color:blue;">আর্থিক বিবরণী</span></div>

		<canvas id="chart_<?php echo $gid; ?>"></canvas>

		<div class="summary">
			<div class="box income">Income <span><?php echo number_format($income); ?></span></div>
			<div class="box expense">Expense <span><?php echo number_format($expense); ?></span></div>
			<div class="box funding">Funding <span><?php echo number_format($fund); ?></span></div>
			<div class="box" style="color:#9b59b6;">Loan <span><?php echo number_format($loan); ?></span></div>
		</div>
	</div>
	
	<script>
		new Chart(document.getElementById('chart_<?php echo $gid; ?>'), {
			type: 'bar',
			data: {
				labels: ['আয়', 'ব্যয়', 'তহবিল', 'ঋণ'],
				datasets: [{
					data: [<?php echo $income; ?>, <?php echo $expense; ?>, <?php echo $fund; ?>, <?php echo $loan; ?>],
					backgroundColor: [
						'rgba(46, 204, 113, 0.7)',
						'rgba(231, 76, 60, 0.7)',
						'rgba(52, 152, 219, 0.7)',
						'rgba(155, 89, 182, 0.7)'
					],
					borderRadius: 10
				}]
			},
			options: {
				plugins: { legend: { display: false } },
				scales: { y: { beginAtZero: true } }
			}
		});
	</script>
	
	<?php } ?>
	
	<!-- Chart Area End -->
	<div id="menu_div">
			
	</div>
	<!-- Funding Chart Area Start -->
	<?php
		$gardens = $conn->query("SELECT garden_id, garden_name FROM gardenindex");

		while($g = $gardens->fetch()) {

			$gid = $g['garden_id'];
			$gname = $g['garden_name'];

			// Get owners funding per garden
			$sql = "SELECT 
						o.owner_name,
						o.owner_photo,
						SUM(f.fund_amount) AS total_fund
					FROM fund f
					JOIN owner o ON f.owner_id = o.owner_id
					WHERE f.garden_id = $gid
					GROUP BY f.owner_id";

			$stmt = $conn->query($sql);

			$names = [];
			$photos = [];
			$amounts = [];

			while($row = $stmt->fetch()) {
				$names[] = $row['owner_name'];
				$photos[] = 'owners/' . $row['owner_photo'];
				$amounts[] = $row['total_fund'];
			}
	?>
	<div class="chart-container">
		<div class="chart-title"><?php echo $gname; ?><br><span style="color:blue;">তহবিল সংগ্রহ</span></div>
		<canvas id="owner_chart_<?php echo $gid; ?>"></canvas>
	</div>
	
	<script>
		const images_<?php echo $gid; ?> = <?php echo json_encode($photos); ?>;

		const imageObjects_<?php echo $gid; ?> = images_<?php echo $gid; ?>.map(src => {
			const img = new Image();
			img.src = src;
			return img;
		});

		// Custom plugin to draw images
		const imagePlugin_<?php echo $gid; ?> = {
			id: 'imagePlugin_<?php echo $gid; ?>',
			afterDatasetsDraw(chart) {
				const {ctx, chartArea, scales} = chart;
				const xAxis = scales.x;

				ctx.save();
				ctx.textAlign = "center";

				chart.data.datasets[0].data.forEach((value, index) => {
					const x = xAxis.getPixelForValue(index);
					const img = imageObjects_<?php echo $gid; ?>[index];

					const baseY = chartArea.bottom + 10; // 👈 BELOW chart

					if (img.complete) {
						// Draw image BELOW chart
						ctx.drawImage(img, x - 20, baseY, 40, 40);
					}

					// Draw amount under image
					ctx.font = "15px Arial";
					ctx.fillStyle = "#27ae60";
					ctx.fillText(value.toLocaleString(), x, baseY + 55);
				});

				ctx.restore();
			}
		};

		new Chart(document.getElementById('owner_chart_<?php echo $gid; ?>'), {
			type: 'bar',
			data: {
				labels: <?php echo json_encode($names); ?>,
				datasets: [{
					data: <?php echo json_encode($amounts); ?>,
					backgroundColor: 'rgba(52, 152, 219, 0.7)',
					borderRadius: 10
				}]
			},
			options: {
				layout: {
					padding: {
						bottom: 80   // 👈 creates space for image + text
					}
				},
				plugins: {
					legend: { display: false }
				},
				scales: {
					x: {
						ticks: { display: false }
					},
					y: {
						beginAtZero: true
					}
				}
			},
			plugins: [imagePlugin_<?php echo $gid; ?>]
		});
	</script>
	
	<?php } ?>
	
	<!-- Funding Chart Area End -->
	
	

	<div id="main">
		<div id="left">
			
		</div>
		<div id="center">
			<h2 class="sub-head">Garden List (বাগানের তালিকা)</h2> 
			<table width="80%" border="1" align="center">
				<tr>
					<th>Garden ID</th>
					<th>Garden Name (বাগানের নাম)</th>								
					<th>Owners (মালিকগণের নাম)</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								g.garden_id,
								g.garden_name,
							GROUP_CONCAT(o.owner_name ORDER BY o.owner_id ASC) AS owners
							FROM gardenindex g
							LEFT JOIN owner o 
							ON FIND_IN_SET(g.garden_id, o.garden_index)
							GROUP BY g.garden_id, g.garden_name;';
					$stmt = $conn->query($sql);
					while($row = $stmt->fetch())
					{
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['garden_id'] . '</td>';
						echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
						echo '<td style="text-align:left;">';
						$owners_list = explode(',', $row['owners']);
						$i = 1;
						foreach($owners_list as $owner)
						{
							echo '&nbsp;' . $i++ . '. &nbsp; ' . $owner . '<br>';
						}
						echo '</td>';
						echo '</tr>';
					}
				?>
			</table>
			
			<h2 class="sub-head">Owner List (মালিকগণের তালিকা)</h2> 
			<table width="80%" border="1" align="center">
				<tr>
					<th>Owner ID</th>
					<th>Owner Photo</th>
					<th>Owner Name</th>
					<th>Garden List</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								o.owner_id,
								o.owner_name,
								o.owner_photo,
								o.garden_index,
							GROUP_CONCAT(g.garden_name) AS garden_names
							FROM owner o
							LEFT JOIN gardenindex g 
							ON FIND_IN_SET(g.garden_id, o.garden_index)
							GROUP BY o.owner_id, o.owner_name, o.owner_photo, o.garden_index;';
					$stmt = $conn->query($sql);
					while($row = $stmt->fetch())
					{
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['owner_id'] . '</td>';
						echo '<td style="text-align:center;"><img src="owners/' . $row['owner_photo'] . '" height="100" width="100"</td>';
						echo '<td style="text-align:left;">&nbsp;' . $row['owner_name'] . '</td>';
						echo '<td style="text-align:left;">';
						$garden_names = explode(',', $row['garden_names']);
						$i = 1;
						foreach($garden_names as $garden)
						{
							echo '&nbsp;' . $i++ . '. &nbsp; ' . $garden . '<br>';
						}
						echo '</td>';
						echo '</tr>';
					}
				?>
			</table>
			
			<h2 class="sub-head">Fin Partners List (আর্থিক সহযোগীগণের তালিকা)</h2>
			<table width="80%" border="1" align="center">
				<tr>
					<th>Partner ID</th>
					<th>Partner Photo</th>								
					<th>Partner Name</th>								
					<th>Partner Institution</th>								
					<th>Sponsored Garden</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								p.partner_id,
								p.partner_name,
								p.partner_inst,
								p.partner_photo,
								p.garden_index,
								g.garden_name											
							FROM fin_partner p
							LEFT JOIN gardenindex g ON g.garden_id = p.garden_index;';
					$stmt = $conn->query($sql);
					while($row = $stmt->fetch())
					{
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['partner_id'] . '</td>';
						echo '<td style="text-align:center;"><img src="owners/' . $row['partner_photo'] . '" height="100" width="100"</td>';
						echo '<td style="text-align:left;">' . $row['partner_name'] . '</td>';
						echo '<td style="text-align:left;">' . $row['partner_inst'] . '</td>';
						echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
						echo '</tr>';
					}
				?>
			</table>
			
			<h2 class="sub-head">Loan List (লোন সহায়তা তালিকা)</h2>
			<table width="80%" border="1" align="center">
				<tr>
					<th>Loan ID</th>
					<th>Loan Institution</th>
					<th>Loan Purpose</th>
					<th>gardenn Name</th>								
					<th>Loan Amount</th>								
					<th>Taken Date</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								l.loan_id,
								l.loan_inst,
								f.partner_inst,
								f.partner_name,
								l.loan_purpose,
								l.garden_id,
								g.garden_name,
								l.loan_amount,
								l.loan_date
							FROM loan l
							LEFT JOIN fin_partner f ON l.loan_inst = f.partner_id
							LEFT JOIN gardenindex g ON l.garden_id = g.garden_id;';
					$stmt = $conn->query($sql);
					while($row = $stmt->fetch())
					{
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['loan_id'] . '</td>';
						echo '<td style="text-align:left;"><b>' . $row['partner_name'] . '</b><br>' . $row['partner_inst'] . '</td>';
						echo '<td style="text-align:left;">' . $row['loan_purpose'] . '</td>';
						echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
						echo '<td style="text-align:right;">' . number_format($row['loan_amount'], 0, '.', ',') . '/-</td>';
						echo '<td style="text-align:center;">' . $row['loan_date'] . '</td>';
						echo '</tr>';
					}
				?>
			</table>
			
			<h2 class="sub-head">Collected Fund List (তহবিল সংগ্রহ তালিকা)</h2>
			<table width="80%" border="1" align="center">
				<tr>
					<th>Fund ID</th>
					<th>Owner Paid</th>
					<th>Garden Name</th>
					<th>Paid Amount</th>								
					<th>Paid Date</th>								
				</tr>
				<?php
				$sql = 'SELECT 
							f.fund_id,
							f.owner_id,
							o.owner_name,
							f.garden_id,
							g.garden_name,
							f.fund_amount,
							f.fund_date
						FROM fund f
						LEFT JOIN owner o ON f.owner_id = o.owner_id
						LEFT JOIN gardenindex g ON f.garden_id = g.garden_id
						ORDER BY f.garden_id ASC, f.owner_id ASC, f.fund_id ASC;';

				$stmt = $conn->query($sql);

				$current_garden = null;
				$current_owner  = null;

				$owner_total  = 0;
				$garden_total = 0;

				while($row = $stmt->fetch())
				{
					// OWNER change → print owner subtotal
					if ($current_owner !== null && $current_owner != $row['owner_id']) {
						echo '<tr style="font-weight:bold; background:#e8f4ff;">';
						echo '<td colspan="3" style="text-align:right;">Owner Total:</td>';
						echo '<td style="text-align:right;">' . number_format($owner_total, 0, '.', ',') . '/-</td>';
						echo '<td></td>';
						echo '</tr>';

						$owner_total = 0;
					}

					// GARDEN change → print previous owner total + garden total
					if ($current_garden !== null && $current_garden != $row['garden_id']) {

						// print last owner subtotal before garden changes
						if ($owner_total > 0) {
							echo '<tr style="font-weight:bold; background:#e8f4ff;">';
							echo '<td colspan="3" style="text-align:right;">Owner Total:</td>';
							echo '<td style="text-align:right;">' . number_format($owner_total, 0, '.', ',') . '/-</td>';
							echo '<td></td>';
							echo '</tr>';
							$owner_total = 0;
						}

						// garden subtotal
						echo '<tr style="font-weight:bold; background:green; color:white;;">';
						echo '<td colspan="3" style="text-align:right;">Garden Total:</td>';
						echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
						echo '<td></td>';
						echo '</tr>';

						$garden_total = 0;
					}

					$current_garden = $row['garden_id'];
					$current_owner  = $row['owner_id'];

					$owner_total  += $row['fund_amount'];
					$garden_total += $row['fund_amount'];

					// normal row
					echo '<tr>';
					echo '<td style="text-align:center;">' . $row['fund_id'] . '</td>';
					echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
					echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
					echo '<td style="text-align:right;">' . number_format($row['fund_amount'], 0, '.', ',') . '/-</td>';
					echo '<td style="text-align:center;">' . $row['fund_date'] . '</td>';
					echo '</tr>';
				}

				// LAST owner subtotal
				if ($owner_total > 0) {
					echo '<tr style="font-weight:bold; background:#e8f4ff;">';
					echo '<td colspan="3" style="text-align:right;">Owner Total:</td>';
					echo '<td style="text-align:right;">' . number_format($owner_total, 0, '.', ',') . '/-</td>';
					echo '<td></td>';
					echo '</tr>';
				}

				// LAST garden subtotal
				if ($garden_total > 0) {
					echo '<tr style="font-weight:bold; background:green; color:white;">';
					echo '<td colspan="3" style="text-align:right;">Garden Total:</td>';
					echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
					echo '<td></td>';
					echo '</tr>';
				}
				?>
			</table>
			
			<h2 class="sub-head">Income List (আয়ের তালিকা)</h2>
			<table width="80%" border="1" align="center">
				<tr>
					<th>Income ID</th>
					<th>Responsible Owner</th>
					<th>Garden Name</th>
					<th>Income Source</th>								
					<th>Income Amount</th>								
					<th>Income Date</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								i.income_id,
								i.owner_id,
								o.owner_name,
								i.garden_id,
								g.garden_name,
								i.income_source,
								i.income_amount,
								i.income_date
							FROM income i
							LEFT JOIN owner o ON i.owner_id = o.owner_id
							LEFT JOIN gardenindex g ON i.garden_id = g.garden_id
							ORDER BY i.garden_id ASC, i.income_id ASC;';

					$stmt = $conn->query($sql);

					$current_garden = null;
					$garden_total = 0;

					while($row = $stmt->fetch())
					{
						// Garden change → print previous total
						if ($current_garden !== null && $current_garden != $row['garden_id']) {
							echo '<tr style="font-weight:bold; background:green; color:white;">';
							echo '<td colspan="4" style="text-align:right;">Garden Total:</td>';
							echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
							echo '<td></td>';
							echo '</tr>';

							$garden_total = 0;
						}

						$current_garden = $row['garden_id'];
						$garden_total += $row['income_amount'];

						// normal row
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['income_id'] . '</td>';
						echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
						echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
						echo '<td style="text-align:left;">' . $row['income_source'] . '</td>';
						echo '<td style="text-align:right;">' . number_format($row['income_amount'], 0, '.', ',') . '/-</td>';
						echo '<td style="text-align:center;">' . $row['income_date'] . '</td>';
						echo '</tr>';
					}

					// Last garden total
					if ($current_garden !== null) {
						echo '<tr style="font-weight:bold; background:green; color:white;">';
						echo '<td colspan="4" style="text-align:right;">Garden Total:</td>';
						echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
						echo '<td></td>';
						echo '</tr>';
					}
				?>
			</table>
			
			<h2 class="sub-head">Expenditure List (খরচের তালিকা)</h2>
			<table width="80%" border="1" align="center">
				<tr>
					<th>Exp ID</th>
					<th>Expended by</th>
					<th>Garden Name</th>
					<th>Exp Amount</th>								
					<th>Exp Date</th>								
				</tr>
				<?php
					$sql = 'SELECT 
								e.exp_id,
								e.owner_id,
								o.owner_name,
								e.garden_id,
								g.garden_name,
								e.exp_amount,
								e.exp_date
							FROM exp e
							LEFT JOIN owner o ON e.owner_id = o.owner_id
							LEFT JOIN gardenindex g ON e.garden_id = g.garden_id
							ORDER BY e.garden_id ASC, e.exp_id ASC;';
					$stmt = $conn->query($sql);					
					$current_garden = null;
					$garden_total = 0;

					while($row = $stmt->fetch())
					{
						// When garden changes → print previous total
						if ($current_garden !== null && $current_garden != $row['garden_id']) {
							echo '<tr style="font-weight:bold; background:green; color:white;">';
							echo '<td colspan="3" style="text-align:right;">Subtotal:</td>';
							echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
							echo '<td></td>';
							echo '</tr>';

							$garden_total = 0; // reset for next garden
						}

						$current_garden = $row['garden_id'];
						$garden_total += $row['exp_amount'];

						// normal row
						echo '<tr>';
						echo '<td style="text-align:center;">' . $row['exp_id'] . '</td>';
						echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
						echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
						echo '<td style="text-align:right;">' . number_format($row['exp_amount'], 0, '.', ',') . '/-</td>';
						echo '<td style="text-align:center;">' . $row['exp_date'] . '</td>';
						echo '</tr>';
					}

					// print last garden subtotal
					if ($current_garden !== null) {
						echo '<tr style="font-weight:bold; background:green; color:white;">';
						echo '<td colspan="3" style="text-align:right;">Subtotal:</td>';
						echo '<td style="text-align:right;">' . number_format($garden_total, 0, '.', ',') . '/-</td>';
						echo '<td></td>';
						echo '</tr>';
					}
				?>
			</table>
			
			
			
			
			
			
			
			
			
			
			
		</div>
		<div id="right">
			
		</div>
	</div>
	
</body>
</html>



