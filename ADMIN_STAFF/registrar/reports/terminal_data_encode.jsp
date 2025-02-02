<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdateGraduationData() {
	if(document.form_.id_number.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../entrance_data/graduation_data.jsp?stud_id="+document.form_.id_number.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=950,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this data?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	
	document.form_.page_action.value = strAction;
	this.ShowData();

}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "0";
	document.form_.show_data.value = "1";
	document.form_.info_index.value = "";
	document.form_.submit();
}


function PrepareToEdit(){
	//document.form_.info_index.value = strInfoIndex;	
	document.form_.prepareToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.show_data.value = "1";
	document.form_.submit();
}

function ShowData(){
	document.form_.prepareToEdit.value = "0";
	document.form_.show_data.value = "1";
	document.form_.submit();
}

function PrintPg()
{
	
	if (document.form_.prepared.value.length == 0 || 
	    document.form_.certified.value.length == 0 || 
		document.form_.attested.value.length == 0){
	
		alert(" All names are required.");
		document.form_.prepared.focus();
	}else{
		document.form_.print_page.value="1";
		document.form_.submit();
	}
}


	var objCOA;
	var objCOAInput;
	function AjaxMapName() {
		var strIDNumber = document.form_.id_number.value;
		objCOAInput = document.getElementById("coa_info");
		eval('objCOA=document.form_.id_number');
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
		objCOA.value = strID;
		objCOAInput.innerHTML = "";		
		this.ShowData();
	}	
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.* , java.util.Vector" %>
<%
 	boolean bolShowField = false;
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	String strIsEnrollment = WI.getStrValue(WI.fillTextValue("is_enrollment"),"0");

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	boolean bolIsDBTC = strSchCode.startsWith("DBTC");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","terminal_data_encode.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(), 
														"terminal_data_encode.jsp");	
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
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.GraduationDataReport gradReport = new enrollment.GraduationDataReport();

Vector vStudInfo = null;

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo   = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");

if(WI.fillTextValue("id_number").length() > 0 && strSYFrom.length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number")	);
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();	
}
	


//check here if the student has graduation data already. if not cannot proceed.
if( strIsEnrollment.equals("0") && vStudInfo != null && vStudInfo.size() > 0){
	if(strSemester.equals("1"))
		strTemp = strSYFrom;
	else
		strTemp = strSYTo;

	strTemp = " select grad_data_index from graduation_data where is_valid = 1 and stud_index= "+(String)vStudInfo.elementAt(12)+
		"and GRAD_YEAR = "+strTemp+" and SEMESTER  ="+strSemester;
	
	if(dbOP.getResultOfAQuery(strTemp, 0) == null){
		vStudInfo = new Vector();
		strErrMsg = "Student has no graduation data information.";
	}
}




Vector vRetResult = null;
Vector vEditInfo = null;

String strInfoIndex = WI.fillTextValue("info_index");
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");


strTemp = WI.fillTextValue("page_action");
if((vStudInfo != null && vStudInfo.size() > 0) && strTemp.length() > 0){
	if(gradReport.operateOnTerminalReport(dbOP, request, Integer.parseInt(strTemp), (String)vStudInfo.elementAt(5)) == null)
		strErrMsg = gradReport.getErrMsg();
	else{		
		if(strTemp.equals("1"))
			strErrMsg = "Student Data successfully added.";
		if(strTemp.equals("2"))
			strErrMsg = "Student Data successfully updated.";		
			
		strPrepareToEdit = "0";
	}
}



//Vector vSchInfo = null;


if((vStudInfo != null && vStudInfo.size() > 0) && (WI.fillTextValue("show_data").length() > 0 || strPrepareToEdit.equals("1"))){
	vRetResult = gradReport.operateOnTerminalReport(dbOP, request, 3, (String)vStudInfo.elementAt(5));
	if(vRetResult == null)
		strErrMsg = gradReport.getErrMsg();
	else{		
		//vSchInfo = (Vector)vRetResult.remove(0);
		if(vRetResult.size() > 0)
			strInfoIndex = (String)vRetResult.elementAt(0);
		
	}
}


if((vRetResult == null || vRetResult.size() == 0 ) || strPrepareToEdit.equals("1"))
	bolShowField = true;
else
	bolShowField = false;

%>
<form action="./terminal_data_encode.jsp" method="post" name="form_">  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
	<%
	strTemp = "TERMINAL";
	if(strIsEnrollment.equals("1"))
		strTemp = "ENROLLMENT";
	%>
    	<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: <%=strTemp%> DATA ENCODING ::::</strong></font></div></td>
    </tr>
	<tr><td width="87%" height="22" bgcolor="#FFFFFF" style="text-indent:30px;">&nbsp;<font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
	    <td width="13%" align="right" bgcolor="#FFFFFF" >
		<a href="./tesda_reports.htm"><img src="../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    
	<tr >
	    <td height="25">&nbsp;</td>
	    <td>School Year</td>
	    <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        Term : 
        <select name="semester" id="semester">
          <%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
        </select>		</td>
	    </tr>
	<tr >   
    	<td width="3%">&nbsp;</td>
      <td width="12%">ID Number</td>
      <td width="85%" colspan="2">
	 <input name="id_number" type="text" size="16" class="textbox"  onKeyUp="AjaxMapName();"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64" value="<%=WI.fillTextValue("id_number")%>">	 
	  &nbsp; &nbsp;	  
	  <label id="coa_info" style="width:300px; position:absolute"></label></td>
	</tr>
<%
if(strIsEnrollment.equals("0")){
%>
	<tr> 
      <td height="25">&nbsp;</td>      
      <td><div align="right"><a href="javascript:UpdateGraduationData();"><img src="../../../images/update.gif" border="0"></a></div></td>
      <td valign="bottom"><font color="#0000FF" size="1">Click to update Graduation Data</font>      </td>
    </tr>
<%}%>
    <tr><td height="15" colspan="6"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="3"><a href="javascript:ShowData();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
  </table>
  
  
<%

strTemp = "";
if(vStudInfo != null && vStudInfo.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
	
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="5" >Student name : <strong> 
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),
	  	(String)vStudInfo.elementAt(2),5)%></strong>
		<input type="hidden" name="course_index" value="<%=(String)vStudInfo.elementAt(5)%>" >
	</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="23%">TBP ID Number</td>
		<%	
		strTemp = WI.fillTextValue("tbp_id_number");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(3);							
		%>
	  <td width="74%">
	  <%if(bolShowField){%><input type="text" name="tbp_id_number" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Full Qualification (WTR)</td>
		<%			
		strTemp = WI.fillTextValue("full_qualification_wtr");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(4);								
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="full_qualification_wtr" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Qualification (Clustered)</td>
		<%			
		strTemp = WI.fillTextValue("qualification_clustered");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(5);							
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="qualification_clustered" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Qualification (NTR)</td>
		<%		
		strTemp = WI.fillTextValue("qualification_ntr");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(6);							
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="qualification_ntr" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>CoPR Number</td>
		<%		
		strTemp = WI.fillTextValue("copr_number");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(7);					
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="copr_number" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Delivery Mode</td>
		<%		
		strTemp = WI.fillTextValue("delivery_mode");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(8);								
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="delivery_mode" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Industry Sector of Qualification</td>
		<%		
		strTemp = WI.fillTextValue("industry_sector_of_qualification");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(9);				
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="industry_sector_of_qualification" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Others, Please specify</td>
		<%		
		strTemp = WI.fillTextValue("others_please_specify");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(10);
					
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="others_please_specify" class="textbox"  size="80"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
<!--	<tr>
		<td height="25">&nbsp;</td>
		<td>E-Mail</td>
		<%		
		strTemp = WI.fillTextValue("email");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(11);
		
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="email" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>-->
	
	
	
	
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Highest Educational Attainment</td>
		<%		
		strTemp = WI.fillTextValue("highest_educational_attainment");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(12);
		
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="highest_educational_attainment" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
<%if(!bolIsDBTC){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Scholarship</td>
		<%		
		strTemp = WI.fillTextValue("scholarship");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(13);
		
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="scholarship" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
<%}%>	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Training Component</td>
		<%		
		strTemp = WI.fillTextValue("pgs_training_component");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(14);
				
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="pgs_training_component" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Voucher Number</td>
		<%		
		strTemp = WI.fillTextValue("voucher_number");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(15);
								
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="voucher_number" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Client Type</td>
		<%		
		
		strTemp = WI.fillTextValue("client_type");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(16);		
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="client_type" class="textbox"  size="50"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Date Started</td>
		<%		
		strTemp = WI.fillTextValue("date_started");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(17);
							
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="date_started" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Date Finished</td>
		<%		
		strTemp = WI.fillTextValue("date_finished");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(18);
		
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="date_finished" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
<%if(!bolIsDBTC){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Reason for not Finishing</td>
		<%		
		strTemp = WI.fillTextValue("reason_for_not_finishing");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(19);
			
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="reason_for_not_finishing" class="textbox"  size="80"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
<%}

if(bolIsDBTC){%>	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Training Result</td>
		<%		
		strTemp = WI.fillTextValue("training_result");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(24);
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="training_result" class="textbox"  size="80"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
<%}%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Assessment Results</td>
		<%		
		strTemp = WI.fillTextValue("assessment_result");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(20);
						
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="assessment_result" class="textbox" size="80" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Employment Date</td>
		<%		
		strTemp = WI.fillTextValue("employment_date");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(21);
			
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="employment_date" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Name of Employer</td>
		<%		
		strTemp = WI.fillTextValue("name_of_employer");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(22);
						
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="name_of_employer" class="textbox"  size="80"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Address of Employer</td>
		<%		
		strTemp = WI.fillTextValue("address_of_employer");	
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(23);
						
		%>
		<td>
	  <%if(bolShowField){%><input type="text" name="address_of_employer" class="textbox" size="80"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256" value="<%=WI.getStrValue(strTemp)%>">
	  <%}else{%> : <%=WI.getStrValue(strTemp, "&nbsp;")%><%}%></td>
	</tr>	
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center">
			<%if(vRetResult == null || vRetResult.size() == 0){%>
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save data</font>
			<%}else{
			strTemp = "javascript:PrepareToEdit();";
			if(bolShowField)
				strTemp = "javascript:PageAction('2','');";
			
			%>
			<a href="<%=strTemp%>"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update data</font>
			<%}%>
			
			<a href="javascript:ReloadPage()"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to cancel transaction</font>
		</td>
	</tr>
</table>	


<%}%>  
  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="22">&nbsp;</td></tr>
<tr><td height="22" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>" >
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" >
	<input type="hidden" name="page_action" >
	<input type="hidden" name="show_data" >
	<input type="hidden" name="is_enrollment" value="<%=strIsEnrollment%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>