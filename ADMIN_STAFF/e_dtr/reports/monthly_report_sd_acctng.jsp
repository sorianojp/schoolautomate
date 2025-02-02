<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,java.util.Vector, java.util.Calendar" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Monthly Attendance Monitoring</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--

function PrintPage(){
	document.form_.print_page.value="1";
	document.form_.submit();	
}

function ShowRecords(){
	document.form_.print_page.value="0";
	document.form_.show_list.value="1";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.submit();
}

function UpdateMonth(){

	if (document.form_.strMonth.selectedIndex != 0) {
		document.form_.month_label.value = 	
				document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
		if (document.getElementById("month_")) 
			document.getElementById("month_").innerHTML =  
					document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
	}else{
		document.form_.month_label.value = 	"";
		if (document.getElementById("month_")) 
			document.getElementById("month_").innerHTML = "";
	}
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");

		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	//document.form_.print_page.value="";
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strUserId = (String)request.getSession(false).getAttribute("userId");

	if (WI.fillTextValue("print_page").equals("1")){ %>
		<jsp:forward page="./monthly_report_sd_acctng_print.jsp" />
<%	return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-","monthly_report_sd_acctng.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"monthly_report_sd_acctng.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}			

//end of authenticaion code.
int iSearchResult = 0;
ReportEDTR RE = new ReportEDTR(request);


String[] astrMonth={"","January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 


Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){
	vRetResult = RE.getOfcDeptMonthlyReport(dbOP);
	
	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();
}


%>
<form action="./monthly_report_sd_acctng.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
        TARDINESS / AWOL::::</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
	  	<select name="c_index" onChange="ReloadPage()">
		<option value="">- </option>
	  	<%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0" +
		" order by c_name",WI.fillTextValue("c_index"), false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Office / Dept </td>
      <td colspan="2">
  	  	<select name="d_index">
		<option value="">- </option>
	  	<%=dbOP.loadCombo("d_index","d_name", " from department where is_del = 0 " + 
					WI.getStrValue(WI.fillTextValue("c_index"), 
									" and c_index = ",
									"", " and (c_index is null or c_index = 0)") +
									" order by d_name",
									WI.fillTextValue("d_index"), false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="15%">Employee Type </td>
      <td colspan="2"><select name="teaching_staff">
        <option value="">ALL</option>
		<% if (WI.fillTextValue("teaching_staff").equals("0")){%>
        <option value="0" selected>Non Teaching Personnel</option>
        <%}else{%>
        <option value="0">Non Teaching Personnel</option>
		<%}if (WI.fillTextValue("teaching_staff").equals("1")){%> 
		<option value="1" selected>Teaching Personnel</option>
		<%}else{%> 
		<option value="1">Teaching Personnel</option>
		<%}%> 		
      </select></td>
    </tr>
		<% if(strUserId != null && strUserId.equals("bricks")){ %>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee ID</td>
      <td colspan="2">
			<input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'"  value="<%=WI.fillTextValue("emp_id")%>" size="16" 
			maxlength="32" onKeyUp="AjaxMapName(1);">
			<label id="coa_info" style="position:absolute; width:400px;"></label></td>
    </tr>
		<%}%>		
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Month</td>
      <td colspan="2"><select name="strMonth" onChange="UpdateMonth()">
	    <option value="">Select Month </option>
	  <% 
	  	for (int i = 1; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("strMonth"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>
	  </select><input type="hidden" name="month_label" 
	  				value="<%=WI.fillTextValue("month_label")%>"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Year</td>
<%
	strTemp = WI.fillTextValue("sy_");
	if(strTemp.length() == 0)
		strTemp = WI.getTodaysDate(12);
%>
     <td width="9%"><input name="sy_" type="text" class="textbox" 
	 		onFocus="style.backgroundColor='#D3EBFF'" 
	 		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_')"  
			value="<%=strTemp%>" size="4" maxlength="4" 
			onKeyUp="AllowOnlyInteger('form_','sy_')"></td>
     <td width="73%"><a href="javascript:ShowRecords()"><img src="../../../images/form_proceed.gif" width="81" 
										height="21" border="0"></a></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="19"><hr width="99%" size="1" noshade color="#0000FF"></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;
          <div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            PERSONNEL TARDINESS/ UNDERTIME / AWOL <br>
            FOR THE MONTH OF </font>
		    <label id="month_">&nbsp;	</label>&nbsp;			
		<%=WI.fillTextValue("sy_")%>
		</div></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="13%" rowspan="2" class="thinborder"><strong>&nbsp;UNIT</strong></td>
      <td width="15%" rowspan="2" class="thinborder"><strong> &nbsp;ID #</strong> </td>
      <td width="30%" rowspan="2" class="thinborder"><strong>&nbsp;Name</strong></td>
      <td width="17%" rowspan="2" align="center" class="thinborder"><strong>Tardiness</strong> / <br>
        <strong>Undertime (min)</strong> </td>
      <td height="21" colspan="2" align="center" class="thinborder"><strong>AWOL</strong></td>
    </tr>
    <tr>
      <td width="15%" height="12" class="thinborder"><strong>&nbsp;Date</strong></td>
      <td width="10%" class="thinborder"><strong>&nbsp;Hour(s)</strong></td>
    </tr>
<% 


	Vector vAwol = new Vector();
	int k = 0;
	int iMaxLines = 0;
	
	for (int i = 0; i < vRetResult.size(); i+= 15) {
		iMaxLines = 0;
		vAwol.clear();
		
		if ((Vector)vRetResult.elementAt(i+9) != null) 
			vAwol.addAll((Vector)vRetResult.elementAt(i+9));
			
		if ((Vector)vRetResult.elementAt(i+10) != null)
			vAwol.addAll((Vector)vRetResult.elementAt(i+10));		
			
		if (vAwol != null && vAwol.size()/2 > iMaxLines)
			iMaxLines = vAwol.size()/2;

	if (iMaxLines == 0) 
		iMaxLines++;

	for (k = 0; k < iMaxLines;  k++){
	
%> 
    <tr>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+13);
			if (strTemp == null) 
				strTemp = (String)vRetResult.elementAt(i+14);
			
		}else{
			strTemp = "&nbsp;";
		}
	%> 		
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+1);
		}else{
			strTemp = "";
		}
	%> 	  
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+2);
		}else{
			strTemp = "";
		}
	%> 
      <td class="thinborder" height="18">&nbsp;<%=strTemp%></td>
      <% if (k == 0){
	 		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;");
		 }else{
		 	strTemp =  "&nbsp;";
		 }
	  %> 
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;&nbsp;</td>
      <% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	<% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2 +1);
	   else
		strTemp = "&nbsp;";
	%>		   
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(strTemp, false)%></td>
    </tr>
<%
 }// end employee.. 
}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
  	<td align="center">
	<a href="javascript:PrintPage()"> <img src="../../../images/print.gif" border="0"></a>	</td>
  </tr>
  </table>
<%}%> 
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_page" value="0">
<input type="hidden" name="show_list" value="">
<input type="hidden" name="sd"  value="<%=WI.fillTextValue("sd")%>">
<script language="javascript">
	UpdateMonth();
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>