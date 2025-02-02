<%@ page language="java" import="utility.*,cashcard.CardManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);	
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>View Card Balance Page</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function PrintPage(){
		document.form_.print_all_page.value = "1";
		document.form_.submit();
	}

	function AjaxMapName() {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		/** do not do anything **/
		document.form_.stud_id.value = strID;
		this.ViewLedger();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
		//document.form_.charge_to_name.value = strName;
	}
	
	function UpdateNameFormat(strName) {
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function ViewLedger(){
		document.form_.print_all_page.value = "";
		document.form_.view_ledger.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.stud_id.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_all_page").length() > 0){ %>
		<jsp:forward page="./card_balance_print.jsp"></jsp:forward>
<%	return;}
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CASH CARD BALANCE INQUIRY"),"0"));
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
								"Admin/staff-Cash Card-CASH CARD BALANCE INQUIRY","card_balance.jsp");	
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
	
	Vector vRetResult = null;
	Vector vStudInfo = null;
	double cardBalance = 0d; // total balance of the card | also for evaluation of the entered amount if higher than then total card balance
	int iSearchResult = 0;
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};//not currently used
	String[] astrConvertYrLevelBasic = {"N/A", "Nursery", "Kinder I", "Kinder II", "Grade I", "Grade II", "Grade III", "Grade IV", 
										"Grade V", "Grade VI", "Grade VII", "First Year", "Second Year", "Third Year", "Fourth Year"};
	
	CardManagement cm = new CardManagement();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	
	String strStudID = WI.fillTextValue("stud_id");
	
	if(WI.fillTextValue("view_ledger").length() > 0) {
		if(strStudID.length() > 0) {
			if(bolIsSchool) {
				vStudInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));				
				if(vStudInfo == null) //may be it is the teacher/staff
				{
					request.setAttribute("emp_id",request.getParameter("stud_id"));
					vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
					if(vStudInfo != null)
						bolIsStaff = true;
				}
				else {//check if student is currently enrolled
					Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
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
				request.setAttribute("emp_id",request.getParameter("stud_id"));
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vStudInfo != null)
					bolIsStaff = true;
				if(vStudInfo == null)
					strErrMsg = "Employee Information not found.";
			}
		}
		else
			strErrMsg = "Please provide ID Number.";
		
		if(vStudInfo != null){
			String strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
			
			vRetResult = cm.generateStudentLedger(dbOP, request, strUserIndex);
			if(vRetResult == null)
				strErrMsg = cm.getErrMsg();
			else
				iSearchResult = cm.getSearchCount();
		}
	}//only if vStudInfo is not null;
%>		
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./card_balance.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: VIEW CASH CARD BALANCE ::::</strong></font></td>
		</tr>		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" with="3%"></td>
			<td width="17%">ID Number: &nbsp;&nbsp;&nbsp; </td>
			<td width="80%">
				<input name="stud_id" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();" value="<%=strStudID%>" size="16">
				&nbsp;&nbsp;&nbsp;
				<a href="javascript:ViewLedger();"><img src="../../images/form_proceed.gif" border="0" /></a>
				&nbsp;&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label></td>
		</tr>
	</table>
	
<%if(vStudInfo != null) {%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(!bolIsStaff){%>
    	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Student Name : </td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4)%></strong></td>
			<td width="13%">Status : </td>
			<td width="24%"><%if(bolIsStudEnrolled){%>Currently Enrolled<%}else{%>Not Currently Enrolled<%}%></td>
		</tr>
<%if(!bolBasicStudent){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major :</td>
			<td height="25" colspan="3">
				<%
					strTemp = WI.getStrValue((String)vStudInfo.elementAt(7));
					strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(8));
					if(strErrMsg.length() > 0)
						strTemp += "/" + strErrMsg;
				%>
		    <%=strTemp%></td>
		</tr>
<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Year :</td>
			<td colspan="3">
				<%
					if(bolBasicStudent)
						strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(14)));
					else
						strTemp = astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(14))];
				%>
				<%=strTemp%></td>
		</tr>
	<%}else{%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Emp. Name :</td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4)%></strong></td>
			<td width="13%">Emp. Status :</td>
			<td width="24%"><strong><%=(String)vStudInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office :</td>
			<td><strong><%=WI.getStrValue(vStudInfo.elementAt(13))%>/<%=WI.getStrValue(vStudInfo.elementAt(14))%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vStudInfo.elementAt(15)%></strong></td>
		</tr>
	<%}//only if staff %>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%"></td>
			<td width="17%">Card Balance:</td>
			<td width="80%">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(vRetResult.size() - 2);
					else
						strTemp = "0";
					strTemp = CommonUtil.formatFloat(strTemp, true);
				%>
				<%=strTemp%></td>			
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%}//only if vStudInfo != null

if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr><td align="right">
		<a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0" /></a>
		<font size="1">Click to print report</font>
	</td></tr>
</table>



	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  CASH CARD LEDGER ::: </strong></div></td>
		</tr>
		<%if(cm.defSearchSize != 0){%>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(cm.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td height="25" colspan="3" class="thinborderBOTTOM">
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/cm.defSearchSize;		
				if(iSearchResult % cm.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+cm.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ViewLedger();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
		  		<%}%></td>
		</tr>
		<%}%>
		<tr>
		  	<td width="12%" height="25" align="center" class="thinborder"><strong>Date</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Reference # </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Particulars</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Collected by</strong></td>			
			<td width="12%" align="center" class="thinborder"><strong>Debit</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Credit</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Balance</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 8){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<td class="thinborder">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i), " (Location: ", ")", "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				if(Double.parseDouble(strTemp) > 0d)
					strTemp = CommonUtil.formatFloat(strTemp, true);
				else
					strTemp = "&nbsp;";
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				if(Double.parseDouble(strTemp) > 0d)
					strTemp = CommonUtil.formatFloat(strTemp, true);
				else
					strTemp = "&nbsp;";
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%>&nbsp;</td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"></td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_ledger" />
	<input type="hidden" name="print_page" value="1"  />
	<input type="hidden" name="print_all_page" />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>