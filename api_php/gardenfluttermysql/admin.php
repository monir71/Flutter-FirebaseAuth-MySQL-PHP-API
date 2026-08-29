<?php
	session_start();
	require_once('db_config.php');
?>
<!DOCTYPE html>
<html>
<head>
	
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
		form label {
			font-size:20px;
			color:green;
		}
		form input {
			font-size:25px;
			background:#E8E9EB;
			color:#6366f1;
			border-radius: 8px;
		}
		form select {
			font-size:25px;
			background:#E8E9EB;
			color:#6366f1;
			border-radius: 8px;
		}
		form select option {
			font-size:25px;
			background:#E8E9EB;
			color:#6366f1;
			border-radius: 8px;
		}
		a {
			text-decoration:none;
		}
		.pretty-btn {
		  background-color: #6366f1; /* Modern indigo */
		  color: white;
		  padding: 12px 24px;
		  border: none;
		  border-radius: 8px; /* Rounded corners */
		  font-size: 20px;
		  font-weight: 600;
		  cursor: pointer;
		  transition: all 0.3s ease; /* Smooth hover transition */
		  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
		}
		.pretty-btn:hover {
		  background-color: #4f46e5;
		  transform: translateY(-2px); /* Slight lift effect */
		  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
		}

		.pretty-btn:active {
		  transform: translateY(0); /* Pressed effect */
		}
		.sub-head {
		  background-color: #6366f1; /* Modern indigo */
		  color: white;
		  text-align:center;
		  text-transform:uppercase;
		  padding: 12px 24px;
		  border: none;
		  border-radius: 8px; /* Rounded corners */
		  font-size: 2em;
		  font-weight: 600;
		  transition: all 0.3s ease; /* Smooth hover transition */
		  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
		}
	</style>
</head>
<body>
	<div id="menu_div">
		<h1 class="sub-head" style="font-size:3em;" >Admin : Garden Database</h1>
		<h3><a class="pretty-btn" href="?task=add_fund">Add Fund</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_exp">Add Expenditure</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_loan">Add Loan</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_income">Add Income</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_owner">Add Owner</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_garden">Add Garden</a> &nbsp; &nbsp; <a class="pretty-btn" href="?task=add_fin_partner">Add Fin Partner</a></h3>
	</div>

	<div id="main">
		<div id="left">
			
		</div>
		<div id="center">
			
			<?php
				if(isset($_GET['task']))
				{
					if($_GET['task'] == "add_fund")
					{
						$_SESSION['token'] = rand(100, 1000);
					?>
						<h2 class="sub-head">Add Fund</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
							<label>Select Partner</label><br>
							<select name="partner_fund">
								<?php
									$sql = 'SELECT owner_id, owner_name FROM owner';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['owner_id']; ?>" size="50"><?php echo $row['owner_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Select Garden</label><br>
							<select name="garden_fund">
								<?php
									$sql = 'SELECT garden_id, garden_name FROM gardenindex';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['garden_id']; ?>" size="50"><?php echo $row['garden_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Amount (Tk.)</label><br>
							<input type="number" name="fund_amount" size="10"><br><br>
							<input type="hidden" name="default_fund_amount" value="<?php echo $_SESSION['token']; ?>">
							<label>Deposit Date (DD/MM/YYYY)</label><br>
							<input type="text" name="fund_date" size="10" value="<?php echo date('d/m/Y'); ?>"><br><br>
							<input class="pretty-btn" type="submit" name="add_fund_submit" value="Submit Fund"><br><br>
						</form>
						<h2 class="sub-head">Fund List</h2>
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
										LEFT JOIN gardenindex g ON f.garden_id = g.garden_id;';
								$stmt = $conn->query($sql);
								while($row = $stmt->fetch())
								{
									echo '<tr>';
									echo '<td style="text-align:center;">' . $row['fund_id'] . '</td>';
									echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
									echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
									echo '<td style="text-align:right;">' . number_format($row['fund_amount'], 0, '.', ',') . '/-</td>';
									echo '<td style="text-align:center;">' . $row['fund_date'] . '</td>';
									echo '</tr>';
								}
							?>
						</table>
					<?php
					}
					else if($_GET['task'] == "add_exp")
					{
						$_SESSION['token'] = rand(100, 1000);
					?>
						<h2 class="sub-head">Add Expenditure</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
							<label>Expended by</label><br>
							<select name="partner_exp">
								<?php
									$sql = 'SELECT owner_id, owner_name FROM owner';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['owner_id']; ?>" size="50"><?php echo $row['owner_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Expenditure Name</label><br>
							<datalist id="exp_fields">
							<?php
								$sql = 'SELECT DISTINCT exp_desc FROM exp';
								$stmt = $conn->query($sql);
								while($row = $stmt->fetch())
								{
							?>								
								<option value="<?php echo $row['exp_desc']; ?>">
							<?php
								}
							?>
							</datalist>
							<input type="text" name="exp_desc" list="exp_fields"><br><br>
							<label>Select Garden</label><br>
							<select name="garden_exp">
								<?php
									$sql = 'SELECT garden_id, garden_name FROM gardenindex';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['garden_id']; ?>" size="50"><?php echo $row['garden_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Amount (Tk.)</label><br>
							<input type="number" name="exp_amount" size="10"><br><br>
							<input type="hidden" name="default_exp_amount" value="<?php echo $_SESSION['token']; ?>">
							<label>Expenditure Date (DD/MM/YYYY)</label><br>
							<input type="text" name="exp_date" size="10" value="<?php echo date('d/m/Y'); ?>"><br><br>
							<input class="pretty-btn" type="submit" name="add_exp_submit" value="Submit Expenditure"><br><br>
						</form>
						<h2 class="sub-head">Expenditure List</h2>
						<table width="80%" border="1" align="center">
							<tr>
								<th>Exp ID</th>
								<th>Expended by</th>
								<th>Garden Name</th>
								<th>Description</th>
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
											e.exp_date,
											e.exp_desc
										FROM exp e
										LEFT JOIN owner o ON e.owner_id = o.owner_id
										LEFT JOIN gardenindex g ON e.garden_id = g.garden_id
										ORDER BY e.exp_id DESC;';
								$stmt = $conn->query($sql);
								while($row = $stmt->fetch())
								{
									echo '<tr>';
									echo '<td style="text-align:center;">' . $row['exp_id'] . '</td>';
									echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
									echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
									echo '<td style="text-align:left;">' . $row['exp_desc'] . '</td>';
									echo '<td style="text-align:right;">' . number_format($row['exp_amount'], 0, '.', ',') . '/-</td>';
									echo '<td style="text-align:center;">' . $row['exp_date'] . '</td>';
									echo '</tr>';
								}
							?>
						</table>
					<?php	
					}
					else if($_GET['task'] == "add_loan")
					{
						$_SESSION['token'] = rand(100, 1000);
					?>
						<h2 class="sub-head">Add Loan</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
							<label>Institution</label><br>
							<select name="loan_inst">
								<?php
									$sql = 'SELECT partner_id, partner_inst FROM fin_partner';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['partner_id']; ?>" size="50"><?php echo $row['partner_inst']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Loan Purpose</label><br>
							<input type="text" name="loan_purpose"><br><br>
							<label>Select Garden</label><br>
							<select name="garden_loan">
								<?php
									$sql = 'SELECT garden_id, garden_name FROM gardenindex';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['garden_id']; ?>" size="50"><?php echo $row['garden_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Amount (Tk.)</label><br>
							<input type="number" name="loan_amount" size="10"><br><br>
							<input type="hidden" name="default_loan_amount" value="<?php echo $_SESSION['token']; ?>">
							<label>Loan Date (DD/MM/YYYY)</label><br>
							<input type="text" name="loan_date" size="10" value="<?php echo date('d/m/Y'); ?>"><br><br>
							<input class="pretty-btn" type="submit" name="add_loan_submit" value="Submit Loan"><br><br>
						</form>
						<h2 class="sub-head">Loan List</h2>
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
					<?php	
					}
					else if($_GET['task'] == "add_income")
					{
						$_SESSION['token'] = rand(100, 1000);
					?>
						<h2 class="sub-head">Add Income</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
							<label>Sold by</label><br>
							<select name="sold_by">
								<?php
									$sql = 'SELECT owner_id, owner_name FROM owner';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['owner_id']; ?>" size="50"><?php echo $row['owner_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Income Source</label><br>
							<input type="text" name="income_source"><br><br>
							<label>Select Garden</label><br>
							<select name="garden_income">
								<?php
									$sql = 'SELECT garden_id, garden_name FROM gardenindex';
									$stmt = $conn->query($sql);
									while($row = $stmt->fetch())
									{
								?>
									<option value="<?php echo $row['garden_id']; ?>" size="50"><?php echo $row['garden_name']; ?></option>
								<?php
									}
								?>
							</select><br><br>
							<label>Amount (Tk.)</label><br>
							<input type="number" name="income_amount" size="10"><br><br>
							<input type="hidden" name="default_income_amount" value="<?php echo $_SESSION['token']; ?>">
							<label>Income Date (DD/MM/YYYY)</label><br>
							<input type="text" name="income_date" size="10" value="<?php echo date('d/m/Y'); ?>"><br><br>
							<input class="pretty-btn" type="submit" name="add_income_submit" value="Submit Income"><br><br>
						</form>
						<h2 class="sub-head">Income List</h2>
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
										LEFT JOIN gardenindex g ON i.garden_id = g.garden_id;';
								$stmt = $conn->query($sql);
								while($row = $stmt->fetch())
								{
									echo '<tr>';
									echo '<td style="text-align:center;">' . $row['income_id'] . '</td>';
									echo '<td style="text-align:left;">' . $row['owner_name'] . '</td>';
									echo '<td style="text-align:left;">' . $row['garden_name'] . '</td>';
									echo '<td style="text-align:left;">' . $row['income_source'] . '</td>';
									echo '<td style="text-align:right;">' . number_format($row['income_amount'], 0, '.', ',') . '/-</td>';
									echo '<td style="text-align:center;">' . $row['income_date'] . '</td>';
									echo '</tr>';
								}
							?>
						</table>
					<?php	
					}
					else if($_GET['task'] == "add_owner")
					{
						$_SESSION['token'] = rand(100, 1000);
						
						$stmt = $conn->query("SELECT garden_id, garden_name FROM gardenindex");
						$garden_list = $stmt->fetchAll(PDO::FETCH_ASSOC);						
					?>
						<h2 class="sub-head">Add Owner</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post" enctype="multipart/form-data">							
							<label>Owner Name</label><br>
							<input type="text" name="owner_name"><br><br>
							<label>Select Garden</label><br>
							<select name="garden_index[]" multiple>
								<?php
									foreach ($garden_list as $garden) {
										echo '<option value="' . $garden['garden_id'] . '">'. $garden['garden_name'] . '</option>';
									}
								?>
							</select><br><br>
							<label>Upload Photo</label><br>
							<input type="file" name="file"><br><br>							
							<input type="hidden" name="default_owner_photo" value="<?php echo $_SESSION['token']; ?>">		
							<input class="pretty-btn" type="submit" name="add_owner_submit" value="Submit Owner"><br><br>
						</form>
						<h2 class="sub-head">Owner List</h2>
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
					<?php	
					}
					else if($_GET['task'] == "add_fin_partner")
					{
						$_SESSION['token'] = rand(100, 1000);
						
						$stmt = $conn->query("SELECT garden_id, garden_name FROM gardenindex");
						$garden_list = $stmt->fetchAll(PDO::FETCH_ASSOC);						
					?>
						<h2 class="sub-head">Add Fin Partner</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post" enctype="multipart/form-data">							
							<label>Partner Name</label><br>
							<input type="text" name="partner_name"><br><br>
							<label>Partner Institution</label><br>
							<input type="text" name="partner_inst"><br><br>
							<label>Select Garden</label><br>
							<select name="garden_index[]" multiple>
								<?php
									foreach ($garden_list as $garden) {
										echo '<option value="' . $garden['garden_id'] . '">'. $garden['garden_name'] . '</option>';
									}
								?>
							</select><br><br>
							<label>Upload Photo</label><br>
							<input type="file" name="file"><br><br>							
							<input type="hidden" name="default_partner_photo" value="<?php echo $_SESSION['token']; ?>">		
							<input class="pretty-btn" type="submit" name="add_partner_submit" value="Submit Fin Partner"><br><br>
						</form>
						<h2 class="sub-head">Fin Partners List</h2>
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
					<?php	
					}
					else if($_GET['task'] == "add_garden")
					{
						$_SESSION['token'] = rand(100, 1000);
					?>
						<h2 class="sub-head">Add Garden</h2>
						<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">							
							<label>Garden Name</label><br>
							<input type="text" name="garden_name"><br><br>													
							<input type="hidden" name="default_garden_name" value="<?php echo $_SESSION['token']; ?>">		
							<input class="pretty-btn" type="submit" name="add_garden_submit" value="Submit Garden"><br><br>
						</form>
						<h2 class="sub-head">Garden List</h2>
						<table width="80%" border="1" align="center">
							<tr>
								<th>Garden ID</th>
								<th>Garden Name</th>								
								<th>Owners</th>								
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
					<?php	
					}
				}
				
				if(isset($_POST['add_fund_submit']))
				{
					if($_SESSION['token'] == $_POST['default_fund_amount'])
					{
						$_SESSION['token'] = 0;
												
						$stmt = $conn->prepare("INSERT INTO fund (owner_id, garden_id, fund_amount, fund_date) VALUES (?, ?, ?, ?)");
						$stmt->bindValue(1, $_POST['partner_fund'], PDO::PARAM_INT);
						$stmt->bindValue(2, $_POST['garden_fund'], PDO::PARAM_INT);
						$stmt->bindValue(3, $_POST['fund_amount'], PDO::PARAM_INT);
						$stmt->bindValue(4, $_POST['fund_date'], PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Fund added successfully.';	
					}
				}
				if(isset($_POST['add_exp_submit']))
				{
					if($_SESSION['token'] == $_POST['default_exp_amount'])
					{
						$_SESSION['token'] = 0;
						
						$stmt = $conn->prepare("INSERT INTO exp (owner_id, garden_id, exp_amount, exp_date, exp_desc) VALUES (?, ?, ?, ?, ?)");
						$stmt->bindValue(1, $_POST['partner_exp'], PDO::PARAM_INT);
						$stmt->bindValue(2, $_POST['garden_exp'], PDO::PARAM_INT);
						$stmt->bindValue(3, $_POST['exp_amount'], PDO::PARAM_INT);
						$stmt->bindValue(4, $_POST['exp_date'], PDO::PARAM_STR);
						$stmt->bindValue(5, $_POST['exp_desc'], PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Expenditure added successfully.';
					}
				}
				if(isset($_POST['add_loan_submit']))
				{
					if($_SESSION['token'] == $_POST['default_loan_amount'])
					{
						$_SESSION['token'] = 0;
						
						$stmt = $conn->prepare("INSERT INTO loan (loan_inst, loan_purpose, garden_id, loan_amount, loan_date) VALUES (?, ?, ?, ?, ?)");
						$stmt->bindValue(1, $_POST['loan_inst'], PDO::PARAM_INT);
						$stmt->bindValue(2, $_POST['loan_purpose'], PDO::PARAM_INT);
						$stmt->bindValue(3, $_POST['garden_loan'], PDO::PARAM_INT);
						$stmt->bindValue(4, $_POST['loan_amount'], PDO::PARAM_STR);
						$stmt->bindValue(5, $_POST['loan_date'], PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Loan added successfully.';							
					}
				}
				if(isset($_POST['add_income_submit']))
				{
					if($_SESSION['token'] == $_POST['default_income_amount'])
					{
						$_SESSION['token'] = 0;					
						
						$stmt = $conn->prepare("INSERT INTO income (owner_id, garden_id, income_source, income_amount, income_date) VALUES (?, ?, ?, ?, ?)");
						$stmt->bindValue(1, $_POST['sold_by'], PDO::PARAM_INT);
						$stmt->bindValue(2, $_POST['garden_income'], PDO::PARAM_INT);
						$stmt->bindValue(3, $_POST['income_source'], PDO::PARAM_STR);
						$stmt->bindValue(4, $_POST['income_amount'], PDO::PARAM_INT);
						$stmt->bindValue(5, $_POST['income_date'], PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Income added successfully.';
					}
				}
				if(isset($_POST['add_garden_submit']))
				{
					if($_SESSION['token'] == $_POST['default_garden_name'])
					{
						$_SESSION['token'] = 0;
						
						$stmt = $conn->prepare("INSERT INTO gardenindex (garden_name) VALUES (?)");
						$stmt->bindValue(1, $_POST['garden_name'], PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Garden added successfully.';
					}
				}
				if(isset($_POST['add_owner_submit']))
				{					
					if($_SESSION['token'] == $_POST['default_owner_photo'])
					{
						$_SESSION['token'] = 0;
						
						$owner_name = htmlspecialchars($_POST['owner_name']);
						
						if($_FILES['file']['name'])
						{
							$image = $_FILES['file']['name'];
							$image_name_array = explode('.', $image);

							$unique = time();
					
							$owner_photo = $unique . '.' . $image_name_array[1];						
							
							if($_FILES['file']['type'] == "image/jpeg" || $_FILES['file']['type'] == "image/gif" || $_FILES['file']['type'] == "image/png")
							{
								if($_FILES['file']['size'] < 7000000)
								{
									$tmp_upload_dir = "owners/tmp_" . $owner_photo;
									move_uploaded_file($_FILES['file']['tmp_name'], $tmp_upload_dir);
									
									$permanent_upload_dir = "owners/" . $owner_photo;
									$image_info = getimagesize($tmp_upload_dir);
									
									if($image_info['mime'] == "image/jpeg")
									{
										$resource_handler = imagecreatefromjpeg($tmp_upload_dir);
										imagejpeg($resource_handler, $permanent_upload_dir, 50);
									}
									if($image_info['mime'] == "image/gif")
									{
										$resource_handler = imagecreatefromgif($tmp_upload_dir);
										imagegif($resource_handler, $permanent_upload_dir, 50);
									}
									if($image_info['mime'] == "image/png")
									{
										$resource_handler = imagecreatefrompng($tmp_upload_dir);
										imagepng($resource_handler, $permanent_upload_dir, 5);
									}
									unlink($tmp_upload_dir);
								}
								else
								{
									echo '<h1>Large Image!</h1>';
								}
							}
							else
							{
								echo '<h1>Unsupported Image!</h1>';
							}
						}
						else
						{
							die("No image selected. Please upload an image.");
						}
						
						$garden_index = $_POST['garden_index'];
						$garden_list = '';
						foreach($garden_index as $garden)
						{
							$garden_list .= $garden . ',';
						}
						$garden_index = $garden_list;
						
						$stmt = $conn->prepare("INSERT INTO owner (owner_name, owner_photo, garden_index) VALUES (?, ?, ?)");
						$stmt->bindValue(1, $owner_name, PDO::PARAM_STR);
						$stmt->bindValue(2, $owner_photo, PDO::PARAM_STR);
						$stmt->bindValue(3, $garden_index, PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Owner added successfully.';
						
					}
				}
				
				if(isset($_POST['add_partner_submit']))
				{					
					if($_SESSION['token'] == $_POST['default_partner_photo'])
					{
						$_SESSION['token'] = 0;
						
						$partner_name = htmlspecialchars($_POST['partner_name']);
						$partner_inst = htmlspecialchars($_POST['partner_inst']);
						
						if($_FILES['file']['name'])
						{
							$image = $_FILES['file']['name'];
							$image_name_array = explode('.', $image);

							$unique = time();
					
							$partner_photo = $unique . '.' . $image_name_array[1];						
							
							if($_FILES['file']['type'] == "image/jpeg" || $_FILES['file']['type'] == "image/gif" || $_FILES['file']['type'] == "image/png")
							{
								if($_FILES['file']['size'] < 7000000)
								{
									$tmp_upload_dir = "owners/tmp_" . $partner_photo;
									move_uploaded_file($_FILES['file']['tmp_name'], $tmp_upload_dir);
									
									$permanent_upload_dir = "owners/" . $partner_photo;
									$image_info = getimagesize($tmp_upload_dir);
									
									if($image_info['mime'] == "image/jpeg")
									{
										$resource_handler = imagecreatefromjpeg($tmp_upload_dir);
										imagejpeg($resource_handler, $permanent_upload_dir, 50);
									}
									if($image_info['mime'] == "image/gif")
									{
										$resource_handler = imagecreatefromgif($tmp_upload_dir);
										imagegif($resource_handler, $permanent_upload_dir, 50);
									}
									if($image_info['mime'] == "image/png")
									{
										$resource_handler = imagecreatefrompng($tmp_upload_dir);
										imagepng($resource_handler, $permanent_upload_dir, 5);
									}
									unlink($tmp_upload_dir);
								}
								else
								{
									echo '<h1>Large Image!</h1>';
								}
							}
							else
							{
								echo '<h1>Unsupported Image!</h1>';
							}
						}
						else
						{
							die("No image selected. Please upload an image.");
						}
						
						$garden_index = $_POST['garden_index'];
						$garden_list = '';
						foreach($garden_index as $garden)
						{
							$garden_list .= $garden . ',';
						}
						$garden_index = $garden_list;
						
						$stmt = $conn->prepare("INSERT INTO fin_partner (partner_name, partner_inst, partner_photo, garden_index) VALUES (?, ?, ?, ?)");
						$stmt->bindValue(1, $partner_name, PDO::PARAM_STR);
						$stmt->bindValue(2, $partner_inst, PDO::PARAM_STR);
						$stmt->bindValue(3, $partner_photo, PDO::PARAM_STR);
						$stmt->bindValue(4, $garden_index, PDO::PARAM_STR);
						$stmt->execute();
						
						echo '<h3 style="color:green;">Fin Partner added successfully.';
						
					}
				}
			?>
		</div>
		<div id="right">
			
		</div>
	</div>

	

	

	

	
</body>
</html>

