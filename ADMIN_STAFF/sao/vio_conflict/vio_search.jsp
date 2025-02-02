<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function AjaxMapName() {
	var strIDNumber = document.form_.stud_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strIDNumber.length < 3) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
	
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";		
}

function UpdateName(strFName, strMName, strLName) {
		//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}
function SearchViolation(){
	document.form_.page_action.value="1";
	document.form_.submit();
}
function PrintPg(){
    var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
		
	document.bgColor = "#FFFFFF";
	
	var obj1 = document.getElementById('myADTable1');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable5').deleteRow(0);	
	document.getElementById('myADTable5').deleteRow(0);
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.


}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","vio_search.jsp");
	}catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%return;
	}


	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = 0;
		
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
															"vio_search.jsp");
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
	
   	Vector vRetResult = new Vector();//It has all information.
  	String[] astrSemester = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	
	osaGuidance.ViolationConflict violation = new osaGuidance.ViolationConflict();
	int iElemCount = 0;
	if(WI.fillTextValue("page_action").equals("1")){
	   vRetResult = violation.SearchViolation(dbOP,request);
	   if(vRetResult==null)
	   		strErrMsg = violation.getErrMsg();
	   else
	   	iElemCount = violation.getElemCount();
	
	}

%>
<form action="./vio_search.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH VIOLATIONS &amp; CONFLICTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
       <td width="4%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr> 
	<tr>
		<td width="4%" height="25">&nbsp;</td>
		<td width="13%">Date of violation:</td>
		<% strTemp = WI.fillTextValue("date_from_violation");%>
		<td>				
		<input name="date_from_violation" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"  
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.date_from_violation');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a> To:&nbsp;
		<input name="date_to_violation" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_to_violation');" title="Click to select date"
		onMouseOver="window.status='Select date'; return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0">		</a>	  </td>
		<% strTemp = WI.fillTextValue("date_to_violation");%>
		</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Number of violate:</td>
		<td>
			<input name="num_violate" type="text" value="<%=WI.fillTextValue("num_violate")%>" size="3" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" 
			 onKeyUp="AllowOnlyInteger('form_','num_violate')"
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','num_violate')" >
		<!--
			<select name="num_violate">
			<option value="0"></option>
			<% strTemp = WI.fillTextValue("num_violate");
				if(strTemp.compareTo("1")==0){
			%>	<option value="1" selected="selected">1</option>
			<%}else{%>
			  <option value="1">1</option>
			<%}if(strTemp.compareTo("2")==0){%>
			  <option value="2" selected="selected">2</option>
			  <%}else{%>
			  <option value="2">2</option>
			  <%}%>
			</select>		-->		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Incident type:</td>
		<td>
		<% strTemp= WI.fillTextValue("incident_type");%>
		<select name="incident_type" style="width:300px;">
		<option value="">Select Any</option>
		          <%=dbOP.loadCombo("VIOLATION_TYPE_INDEX","VIOLATION_NAME"," FROM OSA_PRELOAD_VIOL_TYPE ",strTemp,false)%> 
		</select>		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Incident</td>
		<td>
		<%strTemp = WI.fillTextValue("incident");%>
		<select name="incident"  style="width:300px;">
		<option value="">Select Any</option>
		  <%strTemp = WI.fillTextValue("incident");%>
          <%=dbOP.loadCombo("INCIDENT_INDEX","INCIDENT"," FROM OSA_PRELOAD_VIOL_INCIDENT",strTemp,false)%> </select>		  </td>
	</tr>
    <tr>
        <td width="4%" height="25">&nbsp;</td>
		<td>Student ID:</td>
    	<td>
		<input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="" size="16"  onKeyUp="AjaxMapName();"> 
		<label id="coa_info" style="width:400px; position:absolute"></label>	  	</td>
    </tr>
	<tr>
		<td>&nbsp;</td>
		<td>Is cleared:</td>
		<td>
	<%strTemp = WI.fillTextValue("is_clear");
      if (strTemp.equals("1"))
	      strTemp = "checked";
      else
    	  strTemp = "";%>
      <input type="checkbox" name="is_clear" value="1" <%=strTemp%>></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td> SY-Term:</td>
		<td>
		<%  strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		%> 
		<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
			  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
		        -
		<%  strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
		        -
		        <select name="semester">
				<%
				strTemp = WI.fillTextValue("semester");
				if(strTemp.length() ==0)
					strTemp = (String)request.getSession(false).getAttribute("cur_sem");
				%>
				<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>		</td>
	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="2">		
		<a href="javascript:SearchViolation();"> 
		<img src="../../../images/form_proceed.gif" border="0">		</a>		</td>		
	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3"><hr size="1"></td>
	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
  </table> 
  <%if(vRetResult !=null && vRetResult.size()>0){
    String strReportName = null;
	if(WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("semester").length()>0){
	  strReportName = WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to") 
	  +" "+astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
	
	}
  
  %> 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
      <tr>
        <td height="25">
  		  <div align="right"><a href="javascript:PrintPg();">
  		  <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
  		  <font size="1">click to print entries</font>
  		  </div>
  	  </td>
      </tr>
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="9" align="center">
          <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <br><br>
	  <strong>LIST OF VIOLATIONS &amp; CONFLICTS FOR SCHOOL YEAR <%=strReportName%></strong></td>
    </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
    <tr>
      <td width="9%" height="26" class="thinborder"><div align="center"><font size="1"><strong>DATE REPORTED</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>CASE NO</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>INCIDENT TYPE </strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>INCIDENT</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>OFFENSE DESCRIPTION</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>COMPLAINANT</strong></font></div></td>
	  <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>CHARGED PARTY</strong></font></div></td>
    </tr>
    <%for(int i = 0 ; i< vRetResult.size(); i += iElemCount){%>
    <tr>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></font></td>
    </tr>
    <%}%>
  </table>
  <%}//end of vRetResult !=null && vRetResult.size()>0%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable5">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
