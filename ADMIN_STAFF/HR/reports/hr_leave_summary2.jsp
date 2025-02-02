<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Summary per Department/College</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function SearchEmployee(){
	document.form_.view_all.value = '1';
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}
function PrintPg() {//delete rows.. 
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	alert("Click OK to print this report.");
	window.print();
}
///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

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
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	String strErrMsg = null;
	String strTemp = null;
	boolean bolUseYearly = true;

//add security here..

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_summary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolUseYearly = (readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0")).equals("0");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"hr_leave_summary.jsp");
// added for AUF
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
Vector vRetResult       = null;
Vector vLeaveTypeHeader = null; 
HRInfoLeave hrPx = new HRInfoLeave();


if (WI.fillTextValue("view_all").equals("1")) {
	vRetResult = hrPx.getLeaveSummary(dbOP, request);
 
	if (vRetResult == null)
		strErrMsg = hrPx.getErrMsg();
	else
		vLeaveTypeHeader = (Vector)vRetResult.remove(0);
 }
 
 
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");



Vector vLeaveTypes = new Vector();
String strSQLQuery = "select benefit_index, sub_type from hr_benefit_incentive "+
						"join hr_preload_benefit_type on (hr_preload_benefit_type.benefit_type_index = hr_benefit_incentive.benefit_type_index) "+
						"where is_benefit = 0 and benefit_name = 'leave' and is_valid = 1 order by sub_type";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
int iLeaveCount = 0;
while(rs.next()) {
	vLeaveTypes.addElement(rs.getString(1));//[0] benefit_index
	vLeaveTypes.addElement(rs.getString(2));//[1] sub_type
}
rs.close();

String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strTitle    = "Summary of Unused Leave";
if(bolIsSchool)
	strTitle += " for SY " + WI.fillTextValue("sy_from")+" - "+ WI.fillTextValue("sy_to");
else
	strTitle += " for the Year " + WI.fillTextValue("sy_from");
	
String strDateTime = WI.getTodaysDateTime();

int iPageNo      = 0; 
int iTotalPages  = 0;
int iRowCount    = 0;
int iCurRowCount = 0;
%>
<body bgcolor="#FFFFFF">
<form action="./hr_leave_summary2.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr> 
      <td height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
        HR : LEAVE SUMMARY ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <tr> 
      <td width="8%" height="25">&nbsp;Employee ID</td>
      <td width="13%">
			<input name="emp_id"  type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16" 
			maxlength="32" onKeyUp="AjaxMapName();"></td>
      <td width="4%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="55%"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:SearchEmployee();"><label id="coa_info" style="position:absolute;width:350px;"></label>	</td>
    </tr>
    <tr>
      <td height="25" valign="top"><br>&nbsp;Leave Type to Show</td>
      <td height="25" colspan="3">
	  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		  <%while(vLeaveTypes.size() > 0) {
		  strTemp = WI.fillTextValue("_"+iLeaveCount);
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else	
		  	strTemp = "";%>
		  	<tr>
				<td width="25%" class="thinborder" style="font-size:9px;">
					<input type="checkbox" name="_<%=iLeaveCount++%>" value="<%=vLeaveTypes.remove(0)%>" <%=strTemp%>> <%=vLeaveTypes.remove(0)%></td>
				<td width="25%" class="thinborder" style="font-size:9px;">
				<%if(vLeaveTypes.size() > 0) {
					strTemp = WI.fillTextValue("_"+iLeaveCount);
				    if(strTemp.length() > 0) 
					  strTemp = " checked";
				    else	
					  strTemp = "";
			     %>
					<input type="checkbox" name="_<%=iLeaveCount++%>" value="<%=vLeaveTypes.remove(0)%>" <%=strTemp%>> <%=vLeaveTypes.remove(0)%><%}else{%>&nbsp;<%}%></td>
				<td width="25%" class="thinborder" style="font-size:9px;">
				<%if(vLeaveTypes.size() > 0) {
					strTemp = WI.fillTextValue("_"+iLeaveCount);
				    if(strTemp.length() > 0) 
					  strTemp = " checked";
				    else	
					  strTemp = "";
			     %>
					<input type="checkbox" name="_<%=iLeaveCount++%>" value="<%=vLeaveTypes.remove(0)%>" <%=strTemp%>> <%=vLeaveTypes.remove(0)%><%}else{%>&nbsp;<%}%></td>
				<td width="25%" class="thinborder" style="font-size:9px;">
				<%if(vLeaveTypes.size() > 0) {
					strTemp = WI.fillTextValue("_"+iLeaveCount);
				    if(strTemp.length() > 0) 
					  strTemp = " checked";
				    else	
					  strTemp = "";
			     %>
					<input type="checkbox" name="_<%=iLeaveCount++%>" value="<%=vLeaveTypes.remove(0)%>" <%=strTemp%>> <%=vLeaveTypes.remove(0)%><%}else{%>&nbsp;<%}%></td>
			</tr>
		  <%}%>
		  <input type="hidden" name="leave_count" value="<%=iLeaveCount%>">
		</table>
	  </td>
    </tr>
    <% 
	String strCollegeIndex = null;
	strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex);
	%>
    <tr>
      <td height="25">&nbsp;Employee Category</td>
      <td colspan="3">
      <%
	 	strTemp = WI.fillTextValue("employee_category");
	  %>
	  <select name="employee_category" onChange="ReloadPage();">
          <option value=""></option>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (strTemp.equals("1")){%>
          <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
          <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3">
	  	<select name="c_index" onChange="loadDept();"> 
				<option value="">ALL</option>
				<%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0 order by c_name", 
							strCollegeIndex, false)%>
		  </select>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;Office</td>
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	
      <td height="25" colspan="3">
	  	<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
          <%}%>
        </select> 
			</label></td>
    </tr>
		<%if(bolUseYearly){%>
    <tr> 
      <td height="25">&nbsp;<%if(bolIsSchool){%>SY / SEM<%}else{%>Year<%}%>&nbsp;:</td>
      <td height="25" colspan="3"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	if(!bolIsSchool) 
		strTemp = WI.getTodaysDate().substring(0,4);
	else	
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%>
        <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" <%if(bolIsSchool){%>onKeyUp="DisplaySYTo('form_', 'sy_from', 'sy_to')"<%}%>>
        <%
	strSYTo = WI.fillTextValue("sy_to");
	if(strSYTo.length() ==0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
<%if(bolIsSchool){%>
-&nbsp;
<input name="sy_to" type= "text" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" size="4" maxlength="4" 
		onBlur="style.backgroundColor='white'"  value="<%=strSYTo%>" readonly="yes">
&nbsp;&nbsp;
<select name="semester">
  <option value="1"> 1st Sem</option>
  <%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
		if (strTemp.equals("2")) {
	%>
  <option value="2" selected> 2nd Sem</option>
  <%}else{%>
  <option value="2"> 2nd Sem</option>
  <%} if ( strTemp.equals("3")){%>
  <option value="3" selected> 3rd Sem</option>
  <%}else{%>
  <option value="3"> 3rd Sem</option>
  <%}if ( strTemp.equals("0")){%>
  <option value="0" selected> Summer</option>
  <%}else{%>
  <option value="0"> Summer</option>
  <%}%>
</select>
<%}else{///for companies.%>
<input type="hidden" name="sy_to" value="<%=strTemp%>">
<input type="hidden" name="semester" value="1">
<%}%></td>
    </tr>
		<%}%>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
		<tr>
			<td align="right"><font size="2">Number of Employees / rows Per Page :</font>
			  <select name="num_rec_page">
				<% int iRowsPerPg = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"40"));
					for(int i = 15; i <=60 ; i++) {
						if ( i == iRowsPerPg) {%>
				<option selected value="<%=i%>"><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%></option>
				<%}}%>
			  </select>
			  <%if(vRetResult != null && vRetResult.size() > 0) {%>
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print result</font>&nbsp;
			  <%}%>
			</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0) {
double dTotalUsed   = 0d;
double dTotalUnused = 0d;

double dUsed     = 0d;
double dBalance  = 0d;

//iTotalPages = vRetResult.size()/(11 * iRowsPerPg) ;
//if(vRetResult.size() % (11 * iRowsPerPg) > 0) 
//	++iTotalPages;

	while(vRetResult.size() > 0) {
		iCurRowCount = 0;
		if(iPageNo > 0) {%>
			<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%}%>
 
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
		   <font size="1">
				<%=strAddr1%><br><%=strAddr2%><br><strong><%=strTitle%></strong>
				<div align="right">
					Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page# <%=++iPageNo%> <!--of <%//=iTotalPages%>-->
				</div>
		   </font></td>
	  </tr>
	</table>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr style="font-weight:bold">
		    <td width="4%" rowspan="2" class="thinborder" style="font-size:9px;">Count</td> 
			<td width="7%" rowspan="2" class="thinborder"><strong style="font-size:9px;"> ID No.</strong></td>
			<td width="18%" rowspan="2" align="center" class="thinborder" style="font-size:9px;">Name of Employee</td>
			<%for(int i = 0; i < vLeaveTypeHeader.size(); ++i) {%>
				<td height="20" colspan="3" align="center" class="thinborder" style="font-size:9px;"><%=vLeaveTypeHeader.elementAt(i)%></td>
			<%}%>
			<td width="5%" rowspan="2" align="center" class="thinborder" style="font-size:9px;">Total Used</td>
		    <td width="5%" rowspan="2" align="center" class="thinborder" style="font-size:9px;">Total Un-used</td>
		</tr>
		<tr style="font-weight:bold">
			<%for(int i = 0; i < vLeaveTypeHeader.size(); ++i) {%>
			  <td width="5%" height="20" align="center" class="thinborder" style="font-size:9px;">Entitled</td>
			  <td width="5%" align="center" class="thinborder" style="font-size:9px;">Consumed</td>
			  <td width="5%" align="center" class="thinborder" style="font-size:9px;">Un-used</td>
		    <%}%>
	    </tr>
		<%while(vRetResult.size() > 0) {
			strTemp = (String)vRetResult.elementAt(0);
			dTotalUsed = 0d; dTotalUnused = 0d;%>
			<tr>
			  <td height="20" class="thinborder" style="font-size:9px;"><%=++iRowCount%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(5)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(6)%></td>
			  <%for(int i = 0; i < vLeaveTypeHeader.size(); ++i) {
			  	dUsed = 0d; dBalance = 0d;
				if(vRetResult.size() > 0 && strTemp.equals(vRetResult.elementAt(0)) && vLeaveTypeHeader.elementAt(i).equals(vRetResult.elementAt(2))) {
					dUsed    = Double.parseDouble((String)vRetResult.elementAt(4));
					dBalance = Double.parseDouble((String)vRetResult.elementAt(3));
					
					dTotalUsed   += dUsed;
					dTotalUnused += dBalance;
					
					vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
					vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
				}

			  	%>
				  <td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dUsed + dBalance, false)%></td>
				  <td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dUsed, false)%></td>
				  <td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dBalance, false)%></td>
		      <%}%>
			  <td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dTotalUsed, false)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dTotalUnused, false)%></td>
		  </tr>
	   <%
	   ++iCurRowCount;
	   if(iCurRowCount >= iRowsPerPg) 
	   		break;//create page break;
	   
	   }%>
	</table>
<%}//Loop to create page break.. while(vRetResult.size() > 0) 

}%> 


<input type="hidden" name="format2" value="1">
<input type="hidden" name="view_all">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
