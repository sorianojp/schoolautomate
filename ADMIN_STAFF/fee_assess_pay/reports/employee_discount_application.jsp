<%@ page language="java" import="utility.*,java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Employee Discount Application</title>
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">

function UpdateNoAvailment(strAction){
	
	var objCOAInput = document.form_.no_of_availment;
	var strStudID = document.form_.stud_id.value;
	if(strStudID.length == 0){
		if(strAction == "2")
			alert("Student id number is missing.");
		return;
	}
	
	this.InitXmlHttpObject(objCOAInput, 1);
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6404&stud_id="+strStudID+
	"&new_val="+objCOAInput.value+
	"&page_action="+strAction;	
	this.processRequest(strURL);
}

var strType = "0";
function AjaxMapName(strSearchType) {

		strType = strSearchType;
		var strCompleteName = "";
		var objCOAInput = "";
		
		if(strSearchType == "1"){
			strCompleteName = document.form_.stud_id.value;
			objCOAInput = document.getElementById("stud_coa_info");
		}else{
			strCompleteName = document.form_.emp_id.value;
			objCOAInput = document.getElementById("coa_info");
		}
		
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		if(strSearchType == "0")
			strURL += "&is_faculty=1";
		
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
	if(strType == "0"){
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}else{
		document.form_.stud_id.value = strID;
		document.getElementById("stud_coa_info").innerHTML = "";
		this.UpdateNoAvailment('4');
	}
	
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.submit();	
}

/**
strEncodeType
0 - employee performance
1 - non school employee information encoding.
*/
function ManageNonSchoolEmployee(strEncodeType){
	
	var strID = document.form_.emp_id.value;
	
	if(strEncodeType == "0" && strID.length == 0){
		alert("Please provide employee id number.");
		return;
	}
	
	var pgLoc = "./employee_non_school_mgmt.jsp?is_forwarded=1&emp_id="+strID+
	"&encode_type="+strEncodeType+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
	var win=window.open(pgLoc,"OpenSearch",'width=800,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintForm(strStudID){
	if(strStudID.length == 0){
		alert("Student id number not found.");
		return;
	}
	
	var pgLoc = "./employee_discount_application_print.jsp?application_print=1&stud_id_list="+strStudID+
		"&emp_id="+document.form_.emp_id.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value+
		"&sy_from="+document.form_.sy_from.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}	
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function PrintAll(){
	var strStudID = "";
	var maxDisp = document.form_.item_count.value;	
	for(var i =1; i< maxDisp; ++i){
		if(eval('document.form_.save_'+i+'.checked'))
			if(strStudID.length == 0)
				strStudID = eval('document.form_.save_'+i+'.value');
			else
				strStudID += ", "+eval('document.form_.save_'+i+'.value');
	}
	
	if(strStudID.length == 0){
		alert("Please select atleast 1 student to print.");
		return;
	}
	
	var pgLoc = "./employee_discount_application_print.jsp?application_print=1&stud_id_list="+strStudID+
		"&emp_id="+document.form_.emp_id.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value+
		"&sy_from="+document.form_.sy_from.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}

function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String strTemp2   = null;
	String strTemp3   = null;
	String strImgFileExt = null;
    try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Admission slip","employee_discount_application.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
															"employee_discount_application.jsp");														
	
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_personal_data.jsp");
	
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

	Vector vRetResult = null;
	Vector vEmpRec = null;	
	
	boolean bolNonSchool = true;
	int iElemCount= 0;
	String strEmployeeID = WI.fillTextValue("emp_id");
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	enrollment.FAEmpDiscountApplication FAEmpDisc = new enrollment.FAEmpDiscountApplication();


	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(FAEmpDisc.operateOnEmpDiscApplication(dbOP, request, Integer.parseInt(strTemp), WI.fillTextValue("stud_id")) == null)
			strErrMsg = FAEmpDisc.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Entry successfully deleted.";
			if(strTemp.equals("1"))
				strErrMsg = "Entry successfully saved.";
		}
	}	

	
	
	if(strEmployeeID.length() > 0){
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0"); 
		if(vEmpRec == null)
			vEmpRec = FAEmpDisc.operateOnEmpNonSchoolMgmt(dbOP, request, 4);			
		else
			bolNonSchool = false;	
			
		if(vEmpRec == null || vEmpRec.size() == 0)
			strErrMsg = "Employee information not found.";
		else{
			vRetResult = FAEmpDisc.operateOnEmpDiscApplication(dbOP, request, 4, WI.fillTextValue("stud_id"));
			if(vRetResult == null){
				if(strErrMsg == null)
					strErrMsg = FAEmpDisc.getErrMsg();
			}else
				iElemCount = FAEmpDisc.getElemCount();
		}
	}

String[] astrBeneficiaries = {"Self", "Spouse", "1<sup>st</sup> Child", "2<sup>nd</sup> Child", "3<sup>rd</sup> Child"};
%>


<form name="form_" action="employee_discount_application.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: EMPLOYEE DISCOUNT APPLICATION PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td colspan="2"><a href="javascript:ManageNonSchoolEmployee('1');">Manage Non-School Employee</a>		</td>
	    <td><a href="javascript:ManageNonSchoolEmployee('0');">Employee Performance Evaluation</a></td>
	</tr>
	<tr>
	<td height="25">&nbsp;</td>
	<td width="16%">SY-TERM:</td>
      <td  colspan="2">
<%	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
       <select name="semester" >
          <option value="1">1st Sem</option>
<%	 strTemp =WI.fillTextValue("semester");
	 if(strTemp.length() ==0) 
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>      </td>
    </tr>		
	<tr>
     <td width="3%" height="25">&nbsp;</td>
      <td>Employee ID </td>
      <td width="17%">
	  <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16" onKeyUp="AjaxMapName('0');"></td>
	  <td width="64%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle"></a>
	  &nbsp; &nbsp;<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0" align="absmiddle" /></a>
	  &nbsp; &nbsp;
	  <label id="coa_info" style="font-size:11px; position:absolute; width:400px; font-weight:bold; color:#0000FF"></label>	  </td>
  </tr>    
	<tr>
		<td height="4" colspan="4"><hr size="1" /></td>
	  </tr>
  </table>
  <% if ( vEmpRec != null && vEmpRec.size() > 0) {%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<%if(!bolNonSchool){%>
	<tr>
		<td colspan="3" valign="bottom">
			<table width="400" border="0" align="center">
    <tr bgcolor="#FFFFFF">
      <td width="100%" valign="middle"><%strTemp = "<img src=\"../../../upload_img/"+strEmployeeID.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
          <%=WI.getStrValue(strTemp)%> <br>
          <br>
          <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
          <br>
          <strong><%=WI.getStrValue(strTemp)%></strong><br>
          <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
          <font size="1"><%=WI.getStrValue(strTemp3)%></font><br>
          <br>
          <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>		  
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
    </tr>
  </table>		</td>
	</tr>
	<%}else{%>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Employee Name</td>
		<%
		strTemp = WebInterface.formatName((String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),(String)vEmpRec.elementAt(4),5);
		%>
		<td><%=strTemp%></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Position</td>
	    <td><%=(String)vEmpRec.elementAt(5)%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Date of Employment</td>
	    <td><%=(String)vEmpRec.elementAt(6)%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Business / Service Unit</td>
	    <td><%=(String)vEmpRec.elementAt(7)%></td>
	    </tr>
	<%}%>
 </table>

  

 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
 	<tr>
		<td height="4" colspan="4"><hr size="1" /></td>
	  </tr>  
	 <tr>
		<td colspan="4">&nbsp;</td>
	  </tr> 
	 <tr>
	     <td height="25">&nbsp;</td>
	     <td colspan="3">
		 <font style="font-size:10px;">NOTE: Number of availment will show after you enter student id number.</font>
		 </td>
        </tr>
	 <tr>
     <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Student ID</td>
      <td colspan="2">
	  <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="UpdateNoAvailment('4');style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16"  
	  onKeyUp="AjaxMapName('1');">
	  &nbsp; &nbsp;
      <label id="stud_coa_info" style="font-size:11px; position:absolute; width:400px; font-weight:bold; color:#0000FF"></label></td>
  </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Number of availment</td>
	    <td colspan="2">
		 <input name="no_of_availment" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("no_of_availment")%>" size="2" maxlength="2">
	  <a href="javascript:UpdateNoAvailment('2');"><img src="../../../images/update.gif" border="0" /></a>
	  <font size="1">edit this field to the actual count of availment of the student</font>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Relation</td>
	    <td colspan="2">
		<select name="relation">
			<option value="">Please select relation</option>
			<%=dbOP.loadCombo("RELATION_INDEX", "RELATION_NAME", " from HR_PRELOAD_RELATION order by RELATION_NAME ",WI.fillTextValue("relation"), false)%>
		</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Discount</td>
	    <td colspan="2">
		<select name="discount_percentage" style="width:250px;">
			<option value="">Please select discount</option>
			<%=dbOP.loadCombo("PERCENT_INDEX", "PERCENT_NAME", " from FA_EMP_DISCOUNT_PERCENTAGE order by PERCENT_NAME ",WI.fillTextValue("discount_percentage"), false)%>
		</select>
		<a href='javascript:viewList("FA_EMP_DISCOUNT_PERCENTAGE","PERCENT_INDEX","PERCENT_NAME","DISCOUNT", "FA_EMP_DISCOUNT_APPLICATION", "PERCENT_INDEX"," and is_valid = 1","","discount_percentage");'>
		<img src="../../../images/update.gif" border="0" /></a>
		<font size="1">Click to update discount</font>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Beneficiaries to Date:</td>
		<td colspan="2">
		<select name="beneficiaries_to_date" style="width:100px;">
			<%
			strTemp = WI.fillTextValue("beneficiaries_to_date");
			strErrMsg = "";
			for(int i =0; i < astrBeneficiaries.length; ++i){
			%>
			<option value="<%=i%>" <%=strErrMsg%>><%=astrBeneficiaries[i]%></option>
			<%}%>
		</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">
		<a href="javascript:PageAction('1','')"><img src="../../../images/save.gif" border="0" /></a>
		<font size="1">Click to save information</font>		</td>
	    </tr>
  <tr>
  	<td colspan="4">&nbsp;</td>
  </tr> 
  </table>
  
 <%
 if(vRetResult != null && vRetResult.size() > 0){ 
 %> 
 <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
 	<tr><td class="thinborder" colspan="7" align="center" height="22"><strong>LIST OF STUDENT WITH DISCOUNT</strong></td></tr>
	<tr>
		<td width="12%" height="20" class="thinborder"><strong>ID NUMBER</strong></td>
		<td width="24%" class="thinborder"><strong>STUDENT NAME</strong></td>
		<td width="21%" class="thinborder"><strong>GRADE OR YEAR LEVEL &amp; COURSE</strong></td>
		<td width="23%" class="thinborder"><strong>DISCOUNT</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>TYPE</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>OPTION</strong></td>
	    <td width="7%" align="center" class="thinborder">
		<strong>Select All<br />
		</strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">		</td>
	</tr>
	<%
	int iCount = 1;
	for(int i =0; i < vRetResult.size(); i+=iElemCount, ++iCount){%>
	<tr>
		<td height="22" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+8))+WI.getStrValue((String)vRetResult.elementAt(i+9)," / ","","")+
			WI.getStrValue((String)vRetResult.elementAt(i+10)," - ","","");
		if(WI.getStrValue(vRetResult.elementAt(i+13)).equals("1"))
			strTemp = WI.getStrValue(vRetResult.elementAt(i+8))+WI.getStrValue((String)vRetResult.elementAt(i+9)," - ","","");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+19),"&nbsp;")%></td>
		<%
		if(vRetResult.elementAt(i+20) == null)
			strTemp = "&nbsp;";
		else
			strTemp = astrBeneficiaries[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+20)))];
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		<td class="thinborder" align="center">
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i+14)%>')"><img src="../../../images/delete.gif" border="0" /></a>
		&nbsp;
		<a href="javascript:PrintForm('<%=vRetResult.elementAt(i+1)%>')"><img src="../../../images/print.gif" border="0" /></a>		</td>
	    <td class="thinborder" align="center">
		<input type="checkbox" name="save_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>" tabindex="-1"></td>
	</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>" />
 </table>
  
 <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
		<td align="right">
			<a href="javascript:PrintAll();"><img src="../../../images/print.gif" border="0" /></a>
			<font size="1">Click to print all student</font>
		</td>
	</tr>
 </table>
  
 <%}
 }%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action" />
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
  <input type="hidden" name="reload_page">
  <input type="hidden" name="max_application" value="4" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
