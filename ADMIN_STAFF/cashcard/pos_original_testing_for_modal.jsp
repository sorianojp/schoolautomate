<%@ page language="java" import="utility.*, cashcard.Pos, hmsOperation.RestPOS,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>POS Terminal</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">

	function PrintPg(strInfoIndex,strDate,strDate2)
	{
		var loadPg = "./pos_print.jsp?info_index="+strInfoIndex+"&TRANSACTION_DATE="+strDate+"&TRANSACTION_DATE2="+strDate2;	
		var win=window.open(loadPg,"myfile",'dependent=no,width=350,height=350,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function FocusField() {
		document.form_.scan_id.focus();
	}
	
	function PageAction(strAction,strInfoIndex,strOrderIndex){
		if(strAction == '0'){
			if(!confirm("Are you sure you want to delete this customer transaction?"))
				return;
		}
		document.form_.page_action.value = strAction;
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		if(strOrderIndex.length > 0)
			document.form_.order_index.value = strOrderIndex;
		
		document.form_.submit();
	}
	
	function Cancel() {
			
		//in new order. its ok to cancel. 
		//it will delete all the ordered items and update the inventory.
		//
		if(document.form_.prepareToEdit.value != "1") 
			document.form_.cancel_transaction.value = "1";
		else
			document.form_.cancel_edited_order.value = "1";
						
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.order_index.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.submit();
		//location = "./pos.jsp";
	}

	function SearchCollection(strKeyCode){
		if(strKeyCode == '13'){
			document.form_.submit();	
		}
	}
	function LaunchPOS(strStudIndex) {
		var loadPg = "./pos_orders.jsp?stud_="+strStudIndex;	
		var win=window.open(loadPg,"myfile",'fullscreen=yes,dependent=no, scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function EditTransaction(strPOSMainIndex,strStudIndex,strInfoIndex){
		
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "1";
		
		var loadPg = "./pos_orders.jsp?stud_="+strStudIndex+"&order_index="+strPOSMainIndex;	
		var win=window.open(loadPg,"myfile",'fullscreen=yes,dependent=no, scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	String strDisabled  = null;
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-POS TERMINAL"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-POS TERMINAL","pos.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}						
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	
	Vector vEditInfo  = null; 
	Vector vRetResult = null; 
	Vector vIPResult = null;
	Vector vCardDetails = null;
	Vector vStudInfo  = null; 
	Vector vAllergies = null;
	Vector vFoodPD = null;
	String strTerminalIPIndex = "";
	String strAmtOrdered = "";
	
	// total balance of the card | also for evaluation of the entered amount if higher than then total card balance
	double dBalance = 0d;
	
	// to evaluate if the entered amount is greater than the remaining usage per day
	double dUsableToday = 0d; 
	
	// used to evalute if the transaction amount is higher 
	//than the max usage per day or the remaining card balance
	double dAmount = 0d; 
	
	int i = 0;
	int iSearchResult = 0;
	
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};//not currently used..
	String[] astrConvertYrLevelBasic = {"N/A", "Nursery", "Kinder I", "Kinder II", "Grade I", "Grade II", "Grade III", "Grade IV", 
										"Grade V", "Grade VI", "Grade VII", "First Year", "Second Year", "Third Year", "Fourth Year"};
	
	Pos pos = new Pos();
	RestPOS rPOS = new RestPOS();
	//enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	
	vIPResult = pos.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=pos.getErrMsg()%></p>
		<%
		dbOP.cleanUP();
		return;	
	}
	
	if(((String)vIPResult.elementAt(5)).equals("0")){%>
		<p style="font-weight:bold; font-color:red; font-size:16px;">This terminal is not canteen type.</p>
		<%
		dbOP.cleanUP();
		return;	
	}
	strTerminalIPIndex = (String)vIPResult.elementAt(0);
	
	String strStudID = WI.fillTextValue("stud_id");
	if(WI.fillTextValue("scan_id").length() > 0) 
		strStudID = WI.fillTextValue("scan_id");
	
	if(strStudID.length() > 0){
		if(bolIsSchool) {
			vStudInfo = OAdm.getStudentBasicInfo(dbOP, strStudID);
			if(vStudInfo == null) //may be it is the teacher/staff
			{
				request.setAttribute("emp_id", strStudID);
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vStudInfo != null)
					bolIsStaff = true;
			}
			else {//check if student is currently enrolled
				Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, strStudID,
				(String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(9));
				if(vTempBasicInfo != null){
					bolIsStudEnrolled = true;
					if(((String)vTempBasicInfo.elementAt(5)).equals("0"))
						bolBasicStudent = true;
					//System.out.println("vTempBasicInfo: "+vTempBasicInfo);
				}
			}
			if(vStudInfo == null)
				strErrMsg = OAdm.getErrMsg();
		}
		else{//check faculty only if not school...
			request.setAttribute("emp_id", strStudID);
			vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vStudInfo != null)
				bolIsStaff = true;
			if(vStudInfo == null)
				strErrMsg = "Employee Information not found.";
		}
	}
	String strUserIndex = null;
	if(vStudInfo != null) {
		strUserIndex = (String)vStudInfo.elementAt(12);
		if(bolIsStaff)
			strUserIndex = (String)vStudInfo.elementAt(0);
		if(WI.fillTextValue("order_index").length() > 0){
			strTemp = "select payable_amt from hms_rest_pos_sales_main where pos_sales_main_index = "+WI.fillTextValue("order_index");
			strAmtOrdered = WI.getStrValue(dbOP.getResultOfAQuery(strTemp, 0),"0");
			if(Double.parseDouble(strAmtOrdered) == 0d)
				strAmtOrdered = "";
		}
		
		if(WI.fillTextValue("cancel_transaction").length() > 0){
			if(!rPOS.cancelOrder(dbOP, request))
				strErrMsg = rPOS.getErrMsg();
		}
	
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(strTemp.equals("1")){
				try{
					dBalance = Double.parseDouble(WI.fillTextValue("dBalance"));
					dUsableToday = Double.parseDouble(WI.fillTextValue("dUsableToday"));
					dAmount = Double.parseDouble(WI.getStrValue(WI.fillTextValue("dAmount"), "0"));
					
				}
				catch(NumberFormatException nfe){
					dBalance = 0;
					dUsableToday = 0;
					dAmount = 0;
				}
			}
			else{
				dBalance = 0;
				dUsableToday = 0;
				dAmount = 0;
			}	
			
			if(dAmount > dUsableToday || dAmount > dBalance){
				strErrMsg = "The amount you enter is higher than the card balance/remaining usage.";
			}			
			else{
				if(pos.operateOnTransaction(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null )
					strErrMsg = pos.getErrMsg();
				else {
					if(strTemp.equals("0"))
						strErrMsg = "Transaction successfully removed.";
					else if(strTemp.equals("1"))
						strErrMsg = "Transaction successfully added.";
					else if(strTemp.equals("2"))
						strErrMsg = "Transaction successfully edited.";
						
					strPrepareToEdit = "0";
					strAmtOrdered = "";
				}
			}
		}
		
		if(((String)vIPResult.elementAt(5)).equals("1")){
			vAllergies  = pos.getAllergies(dbOP, request, strUserIndex);
			vFoodPD = pos.getFoodPD(dbOP, request, strUserIndex);
		}
		

		
		vCardDetails = pos.getCardUserDetail(dbOP, strUserIndex);
		if(vCardDetails == null){
			strErrMsg = pos.getErrMsg();
			strDisabled = "disabled=\"disable\"";
		}
		
		if(vCardDetails != null && vCardDetails.size() > 0){		
			//sum from (amount * no units) ==> initial credits
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(5), "0");
			dBalance = Double.parseDouble(strTemp);
			
			//load adjustment: add load adjustments to initial credits
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(4), "0");
			dBalance = dBalance + Double.parseDouble(strTemp);
			
			//usage summary: swipes
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(3), "0");
			dBalance = dBalance - Double.parseDouble(strTemp);
			
			//max usage per day
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(1), "0");
			if(Double.parseDouble(strTemp) > 0){
				//if card balance is greater than the max usage per day, the remaining usage for today is the max usage for today
				//minus the total of the swipes for today
				if(dBalance >= Double.parseDouble(strTemp)){
					dUsableToday = Double.parseDouble(strTemp);
					
					//total swipes for today
					strTemp  = WI.getStrValue((String)vCardDetails.elementAt(2), "0");
					dUsableToday = dUsableToday - Double.parseDouble(strTemp);
				}
				else
					dUsableToday = dBalance;
			}
			else
				dUsableToday = dBalance;//if unlimited, the remaining usage for today is equal to the initial credits for this person
			
			if(dUsableToday <= 0){
				strDisabled = "disabled=\"disable\"";
				strErrMsg = "You have maxed out your usage for today.";
			}
			
			strTemp  = WI.getStrValue((String)vCardDetails.elementAt(0), "0");
			if(Double.parseDouble(strTemp)>=dBalance) 
				strErrMsg = "Your balance is too low.";
			
		}// End of vCardDetail id not null
		
		vRetResult = pos.operateOnTransaction(dbOP, request, 4, strUserIndex);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = pos.getErrMsg();
		else	
			iSearchResult = pos.getSearchCount();

	
	
		
		
		
		
		
	}//only if vStudInfo is not null;
	
%>		
<body bgcolor="#6666B3" onLoad="FocusField();">
<form name="form_" action="./pos.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" colspan="5" align="center"><font color="#FFFFFF" size="+2">
				<strong><%=(String)vIPResult.elementAt(3)%> - POS TERMINAL</strong></font></td>
		</tr>
		<tr>
			<td width="2%" height="25" >&nbsp;</td>
			<td height="25" colspan="4"><strong><font color="#FFFF00" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="13%"><font color="#FFFFFF">Scan/Enter ID :&nbsp;</font></td>
			<td width="27%">
				<input name="scan_id" type="text" class="textbox" value="<%=WI.fillTextValue("scan_id")%>"
					style="font-size:20px; color: #FF0000;height:27px; width: 200px; border: 1px solid #6666B3;"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'
					onkeyup="javascript:SearchCollection(event.keyCode);">
				<input type="hidden" name="stud_id" value="<%=strStudID%>"></td>
			<td>
				<input type="button" name="list" value=" List Transactions " 
					style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
					onClick="javascript:SearchCollection('13');"></td>
		    <td>
			<%if(strUserIndex != null) {%>
					<input type="button" name="list" value=" Launch POS" 
						style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
						onClick="javascript:LaunchPOS('<%=strUserIndex%>');">
			<%}%>
			</td>
		</tr>
		<tr>
			<td colspan="5" ><hr size="1" color="#FFCC00"></td>
		</tr>
	<%if(vStudInfo != null) {%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><font color="#FFFFFF">Name:</font></td>
	  	  	<td>
				<%
					if(!bolIsStaff)
						strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
					else
						strTemp = WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4);
				%>
				<font color="#FFFFFF"><strong><%=strTemp%></strong></font></td>
			<td colspan="2">
				<%
					if(!bolIsStaff){
						if(bolIsStudEnrolled)
							strTemp = "Currently Enrolled";
						else
							strTemp = "Not Currently Enrolled";
					}
					else
						strTemp = (String)vStudInfo.elementAt(16);
				%>
				<font color="#FFFFFF">Status: <strong><%=strTemp%></strong></font></td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
			<td>
				<%
					if(!bolIsStaff)
						strTemp = "Course/Major";
					else{
						if(bolIsSchool)
							strTemp = "College";
						else
							strTemp = "Division";
						strTemp += "/Office:";
					}
				%>
				<font color="#FFFFFF"><%=strTemp%></font></td>
			<td colspan="3">
				<%
					if(!bolIsStaff){
						strTemp = WI.getStrValue((String)vStudInfo.elementAt(7));
						strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(8));
						if(strErrMsg.length() > 0)
							strTemp += "/" + strErrMsg;
					}
					else{
						strTemp = WI.getStrValue((String)vStudInfo.elementAt(13));
						strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(14));
						if(strErrMsg.length() > 0)
							strTemp += "/" + strErrMsg;
					}
				%>
				<font color="#FFFFFF"><strong><%=strTemp%></strong></font></td>
		</tr>
		<tr valign="top">
			<td height="30" >&nbsp;</td>
			<td style="padding-top: 5px">
				<%
					if(!bolIsStaff)
						strTemp = "Year:";
					else
						strTemp = "Designation:";
				%>
				<font color="#FFFFFF"><%=strTemp%></font></td>
			<td style="padding-top: 5px">
				<%
					if(!bolIsStaff){
						if(bolBasicStudent)
							strTemp = astrConvertYrLevelBasic[Integer.parseInt((String)vStudInfo.elementAt(14))];
						else
							strTemp = astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(14))];
					}
					else
						strTemp = (String)vStudInfo.elementAt(15);
				%>
				<font color="#FFFFFF"><strong><%=strTemp%></strong></font></td>
			<td valign="top">
				<table border="0">
					<tr>
						<td><font color="#FFCC00">Card Balance:</font></td>
						<td><font size="+2" color="#FFCC00"><strong><%=CommonUtil.formatFloat(dBalance, true)%></strong></font>
						<input type="hidden" name="dBalance" value="<%=dBalance%>" /></td>
					</tr>
				</table></td>
			<td>
				<table border="0">
					<tr>
						<td><font color="#FFCC00">Todays remaining usage:</font></td>
						<td align="right"><font color="#FFCC00" size="+2"><strong>
							<%=CommonUtil.formatFloat(dUsableToday, true)%></strong><br/></font></td>
							<input type="hidden" name="dUsableToday" value="<%=dUsableToday%>" /> 
					</tr>
					<tr>
						<td><font color="#FFCC00">Todays usage:</font></td>
						<td align="right"><font color="#FFCC00" size="+2"><strong>
							<%
								if(vCardDetails != null && vCardDetails.size() > 0){
									strTemp  = WI.getStrValue((String)vCardDetails.elementAt(2), "0");
									dBalance = Double.parseDouble(strTemp);
							%>
								<%=CommonUtil.formatFloat(dBalance, true)%>
							<%}%>
						</strong></font></td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<td colspan="5" ><hr size="1" color="#FFCC00"></td>
		</tr>
		<tr valign="top">
			<td height="30" colspan="2">
				<!-- First Table -->
				<table border="0" width="100%">
					<tr>
						<td>
							<%
								strTemp = strStudID;
								if (vStudInfo != null && vStudInfo.size() > 0){
									strTemp = "../../upload_img/"+strTemp+"."+strImgFileExt;
									strTemp = "<img src=\""+strTemp+"\" width=130 height=130 border='1'>";
								}%>
								<%=strTemp%></td>
					</tr>
			  </table>			</td>
			<td>
				<!-- Second Table -->
				<div style="overflow:auto; width:auto; height:175px">
				<table border="0" width="100%">
					<tr>
						<td>
						<%
						strTemp = "";
						if(vAllergies != null){%>
							<font color="#FFCC00" size="+1"><strong>Allergy:</strong></font>
							<font color="#FFFFFF" size="+1"><br/> 
								<%for(i = 0; i < vAllergies.size(); i += 2){
									if(strTemp.length() > 0)
										strTemp += ", "+(String)vAllergies.elementAt(i + 1);
									else
										strTemp = (String)vAllergies.elementAt(i + 1);
								}%>
								<%=strTemp%>							</font>							
						<%}%></td>
					</tr>
					<tr>
						<td>
						<%if(vAllergies != null && vFoodPD != null){%>
							<hr size="1" color="#FFCC00">
						<%}
						strTemp = "";
						if(vFoodPD != null){%>
							<font color="#FFCC00" size="+1"><strong> Preference :</strong></font>
							<font color="#FFFFFF" size="+1"><br/> 
							<%for(i = 0; i < vFoodPD.size(); i += 3){
								if(strTemp.length() > 0)
									strTemp += ", ";
								if(((String)vFoodPD.elementAt(i + 2)).equals("1")){
									strTemp += "<font color=\"#003399\">";
									strTemp += (String)vFoodPD.elementAt(i + 1);
									strTemp += "</font>";
								}
								else
									strTemp += (String)vFoodPD.elementAt(i + 1);
							}%>
						  <%=strTemp%>						  </font>
						<%}%></td>
					</tr>
			  </table>
				</div>			</td>
			<td colspan="2">
				<!-- Third Table -->
				<table border="0" width="100%">
			  		<tr>
				  		<td width="23%" style="font-weight:bold; color:#FFFFFF; font-size:14px;">Transaction Date:</td>
						<td width="77%" style="font-weight:bold; color:#FFFFFF; font-size:14px;"><%=WI.formatDate(WI.getTodaysDate(1), 6)%></td>
					</tr>
					<tr>
				  		<td style="font-weight:bold; color:#FFFFFF; font-size:14px;">Amount:</td>
						<input type="hidden" name="dAmount" value="<%=strAmtOrdered%>" />
						
						
						
						<%
						strTemp = "";
						
						
						if(WI.fillTextValue("cancel_edited_order").length() > 0){
							request.getSession(false).removeAttribute("order_items");
							strAmtOrdered = "";
						}
						
						
						
						Vector vOrders = (Vector)request.getSession(false).getAttribute("order_items");							
						if(vOrders != null && vOrders.size() > 0){
							for(i = 1; i < vOrders.size(); i+=11){
								if(strTemp.length() == 0)
									strTemp = (String)vOrders.elementAt(i+1) +"\t("+(String)vOrders.elementAt(i+3)+")\t"+(String)vOrders.elementAt(i+9);
								else
									strTemp += "\r\n" + (String)vOrders.elementAt(i+1) +"\t("+(String)vOrders.elementAt(i+3)+")\t"+(String)vOrders.elementAt(i+9);
								
							}
						}
												
						if(strAmtOrdered != null && strAmtOrdered.length() > 0)
							strAmtOrdered = CommonUtil.formatFloat(strAmtOrdered,false);		
																		
						%>
						<td>
				  			<input type="text" name="amount" size="32" maxlenght="64" class="textbox"  value="<%=strAmtOrdered%>"
								onfocus="style.backgroundColor='#D3EBFF'" 
								onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" <%=strDisabled%> 
								onkeyup="AllowOnlyFloat('form_','amount');" 
							 	readonly="yes"	
								style="font-size:20px; font-weight:bold; color: #FF0000;height:27px; width: 200px; border: 1px solid #6666B3;"></td>
					</tr>
					<tr>
				  		<td valign="top" style="font-weight:bold; color:#FFFFFF; font-size:14px;"><br>Transaction Detail:</td>
						<td>
				  			<textarea name="transaction_note" cols="65" rows="8" class="textbox" 
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strDisabled%> 
								style="color: #FF0000;border: 1px solid #6666B3; font-size:11px;" readonly="readonly"><%=strTemp%></textarea></td>
					</tr>
					<tr>
						<td></td>
						<td height="35">
							<%if(iAccessLevel > 1){
								if(strPrepareToEdit.equals("0")){
							%>
								<input type="button" name="save" value=" Save Transaction " <%=strDisabled%>
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
									onClick="javascript:PageAction('1','','');">								
								<%}else{%>
								<input type="button" name="edit" value=" Edit Transaction " <%=strDisabled%>
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
									onClick="javascript:PageAction('2','','');">								
								<%}%>
								&nbsp;&nbsp;&nbsp;
								<input type="button" value=" Cancel Transaction " 
									style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="Cancel();">
							<%}//if page action > 1%></td>
					</tr>	
			  </table>			</td>
		</tr>
		<tr>
			<td colspan="5" ><hr size="1" color="#FFCC00"></td>
		</tr>
	<%}%> 
</table>
			
<%if(vRetResult != null) {%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#DDDDEE"> 
			<td height="25" class="thinborder" align="center">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="85%" align="center"><font color="#FF0000"><strong>LIST OF TRANSACTIONS </strong></font></td>
						<td width="15%" align="right">
							<font size="2" color="#FF0000">Total:<strong><%=(String)vRetResult.remove(0)%></strong></font></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#FFFFFF">
			<td width="72%" class="thinborderLEFT"><strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=pos.getDisplayRange()%></strong>)</strong></td>
			<td width="28%" class="thinborderRIGHT" height="25"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/pos.defSearchSize;		
			if(iSearchResult % pos.defSearchSize > 0) 
				++iPageCount;
			strTemp = " - Showing("+pos.getDisplayRange()+")";
			
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="SearchCollection('13');">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}
				%>
				</select>
		<%}%></div></td>
		</tr>
	</table>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr style="font-weight:bold" align="center">
			<td height="25" align="center" class="thinborder" width="16%">Operation</td>
			<td align="center" class="thinborder" width="10%">Reference</td> 
			<td align="center" class="thinborder" width="">Transaction Note</td> 
			<td align="center" class="thinborder" width="15%">Transaction Date</td>  
			<td align="center" class="thinborder" width="10%">Amount</td>
		</tr>
	<%for(i = 0; i < vRetResult.size(); i += 11){%>	
		<tr> 
			<td height="25" class="thinborder" align="center">&nbsp;
				<a href="javascript:PrintPg(<%=(String)vRetResult.elementAt(i)%>,'<%=WI.fillTextValue("TRANSACTION_DATE")%>','<%=WI.fillTextValue("TRANSACTION_DATE2")%>');">
					<img src="../../images/print.gif" border="0" /></a>
				&nbsp;
				<a href="javascript:EditTransaction('<%=(String)vRetResult.elementAt(i+10)%>','<%=strUserIndex%>','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/edit.gif" border="0" /></a>
				&nbsp;
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+10)%>');"><img src="../../images/delete.gif" border="0" /></a></td>	
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder" align="right">
				<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true)%>&nbsp;</td>
		</tr>
	<%}//End of vTransResut%>
		<tr bgcolor="#DDDDEE"> 
			<td height="25" colspan="5" class="thinborder" align="center">&nbsp;	  </td>
		</tr>
	</table> 
<%}%>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>"  />
	<input type="hidden" name="terminal_ip_index" value="<%=strTerminalIPIndex%>" />
	<input type="hidden" name="order_index"  value="<%=WI.fillTextValue("order_index")%>"/>
	<input type="hidden" name="cancel_transaction" />
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>"  />
	<input type="hidden" name="cancel_edited_order" value="" />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>