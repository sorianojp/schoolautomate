<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,enrollment.RegTOREncoding,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.

	if (WI.fillTextValue("print_page").length()>0){%>
				<jsp:forward page="grad_candidates_print.jsp" />
	<%	return; 
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<body bgcolor="#D2AE72"><p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	
	
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates.jsp");
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

Vector vRetResult = null;
Vector vEditInfo = null;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
RegTOREncoding rtr = new RegTOREncoding();

if(WI.fillTextValue("stud_id").length() > 0) {
	vRetResult = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vRetResult == null || vRetResult.size()==0){
		strErrMsg = offlineAdm.getErrMsg();
	}else{
		bolShowEditInfo = true;
		strTemp2 = "readonly=\"yes\"";
	}
}

String strInfoIndex = WI.fillTextValue("info_index");

int iPageAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"-1"));
EntranceNGraduationData egd = new EntranceNGraduationData();
if (iPageAction !=-1){
	if (iPageAction == 0){
		vRetResult = rtr.operateOnOTRRemarks(dbOP,request,iPageAction);
		if (vRetResult !=null){
			strErrMsg = " TOR Remark removed successsfully";
		}else{
			strErrMsg = rtr.getErrMsg();
		}
	}else if (iPageAction == 1){
		vRetResult = rtr.operateOnOTRRemarks(dbOP,request,iPageAction);
		if (vRetResult !=null){
			strErrMsg = " TOR Remark  added successsfully";
		}else{
			strErrMsg = rtr.getErrMsg();
		}
	}else if (iPageAction == 2){
		vRetResult = rtr.operateOnOTRRemarks(dbOP,request,iPageAction);
		if (vRetResult !=null){
			strErrMsg = " TOR Remark  edited successsfully";
			strPrepareToEdit = "";
			strInfoIndex ="";
		}else{
			strErrMsg = rtr.getErrMsg();
		}
	}
}

if (strPrepareToEdit.length() > 0){
	vEditInfo = rtr.operateOnOTRRemarks(dbOP,request,3);

	if (vEditInfo == null || vEditInfo.size()==0){
		strErrMsg = egd.getErrMsg();
		vEditInfo = null;
	}
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>


<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord()
{
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function EditRecord()
{
	document.form_.page_action.value = "2";
	document.form_.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strTargetIndex;
	document.form_.submit();
}
function CancelRecord()
{
	location = "./tor_remarks.jsp";
}
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myTable1').deleteRow(0);
	document.getElementById('myTable1').deleteRow(0);

	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);	
	
	
    document.getElementById('myADTable').deleteRow(1);
	this.insRow(0, 1, strInfo);
	
	
	document.getElementById('myTable4').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);
	
	var iCount = eval(document.form_.iCtr.value);
	for (i=0 ; i < iCount; ++i){
		eval('document.form_.edit'+i+'.src = \"../../../images/blank.gif\"');
		eval('document.form_.delete'+i+'.src = \"../../../images/blank.gif\"');
	}
	window.print();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<form name="form_" action="./tor_remarks.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          TOR REMARKS MANAGEMENT PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
    <tr valign="top"> 
      <td height="30" >&nbsp;</td>
      <td height="25" >STUDENT ID</td>
      <td width="18%" height="25" > <% if (vEditInfo !=null) strTemp = (String)vEditInfo.elementAt(1);
	  	else strTemp = WI.fillTextValue("stud_id");
	  %> <input name="stud_id" type="text" class="textbox" id="stud_id" onKeyUp="AjaxMapName('1');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16">      </td>
      <td width="8%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="11%" ><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td width="48%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="30" >&nbsp;</td>
      <td height="25" >SCHOOL YEAR</td>
      <td height="25" colspan="4" > <%
	  if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(4);
	 }else{ 
		if (WI.fillTextValue("sy_from").length() == 0){
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		}else{
			strTemp = WI.fillTextValue("sy_from");
		}
	}
%> <input name="sy_from" type="text" class="textbox" id="sy_from" onKeypress=" if(event.keyCode<46 || event.keyCode > 57) event.returnValue=false;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4" onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%	if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(5);
	 }else{ 
		if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		}else{
		strTemp = WI.fillTextValue("sy_to");
	}
}%> <input name="sy_to" type="text" class="textbox" id="sy_to" value="<%=strTemp%>" size="4" maxlength="4"> 
        &nbsp;&nbsp;SEMESTER : &nbsp;&nbsp; <%	if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(6);
	 }else{ 
		if (WI.fillTextValue("semester").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		}else{
		strTemp = WI.fillTextValue("semester");
	}
}%> <select name="semester">
          <option value="1">1st Sem</option>
          <%
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="28" >&nbsp;</td>
      <td width="12%" height="28" >OPTION</td>
      <td height="28" colspan="4" > <% 
		if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(8);
		else strTemp = WI.fillTextValue("is_bottom");
	 %> <select name="is_bottom">
          <option value="0">ADD AFTER SCHOOL YEAR</option>
          <% if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>ADD BEFORE SCHOOL YEAR</option>
          <%}else{%>
          <option value="1">ADD BEFORE SCHOOL YEAR</option>
          <%}%>
        </select> </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >REMARKS</td>
      <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(7); 
	  	else
	  		strTemp = WI.fillTextValue("remarks");%>
      <td height="25" colspan="4" > <textarea name="remarks" cols="65" class="textbox" <%if(!strSchCode.startsWith("WNU")){%>maxlength="500" onKeyUp="return isMaxLen(this)"<%}%> 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" rows="6"><%=strTemp%></textarea>      </td>
    </tr>
    <tr>
      <td height="35" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="4" >REMARKS(if any). <br>
        To make the line bold, write within &lt;b&gt;&lt;/b&gt; tag. Example : 
        &lt;b&gt;UNIVERSITY OF XYZ &lt;/b&gt;<br>
        --&gt; this will look like <strong>UNIVERSITY OF XYZ <br>
        </strong>To underline word/words, write within &lt;u&gt;&lt;/u&gt; tag. 
        Example : &lt;u&gt;&lt;b&gt;UNIVERSITY OF XYZ &lt;/b&gt;&lt;/u&gt;<br>
        --&gt; this will look like <u><strong>UNIVERSITY OF XYZ </strong></u> </td>
    </tr>
    <tr> 
      <td height="54" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="4" valign="bottom" > <% if (iAccessLevel > 1){
	  	  	if (vEditInfo == null) {
	 %> <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save entries 
        <%}else if (iAccessLevel == 2){%>
        <a href='javascript:EditRecord();'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>click 
        to edit entry </font> <%} // end if (vEditInfo == null)%> <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size=1> click to cancel edit</font> <%} // end iAccessLevel > 1%> </td>
    </tr>
    <tr> 
      <td height="10" colspan="6" >&nbsp;</td>
    </tr>
  </table>
<% if (WI.fillTextValue("stud_id").length() > 0) vRetResult = rtr.operateOnOTRRemarks(dbOP,request,4); 
   int iCtr = 0;
	if (vRetResult !=null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" colspan="5" ><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>print 
          remarks</font></div></td>
    </tr>
    <% for (int i=0; i < vRetResult.size(); i+=9){%>
    <%} // end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="32" class="thinborder" ><div align="center" ><strong>SCHOOL YEAR</strong></div></td>
      <td width="12%" class="thinborder" ><div align="center"><strong>SEMESTER</strong></div></td>
      <td height="32" class="thinborder" ><div align="center"><strong>OPTION</strong></div></td>
      <td class="thinborder" ><div align="center"><strong>REMARKS </strong></div></td>
      <td height="32" class="thinborder" >&nbsp;</td>
    </tr>
   <% String[] astrOption = {"Add After the school year", "Add before the school year"};  
      
			for (int i=0; i < vRetResult.size(); i+=9, iCtr++){%>
    <tr> 
      <td width="12%" height="30" class="thinborder" ><div align="center"><%=(String)vRetResult.elementAt(i+4)+ " - " + (String)vRetResult.elementAt(i+5) %></div></td>
      <td width="10%" class="thinborder" > &nbsp;<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
      <td width="20%" class="thinborder" >&nbsp;<%=astrOption[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
      <td width="43%" class="thinborder" ><div align="center">&nbsp;<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+7),"\n","<br>")%></div></td>
      <td width="12%" class="thinborder" ><a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'>
	  <img src="../../../images/edit.gif" width="40" height="26" border="0" id="edit<%=iCtr%>"></a><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img  id="delete<%=iCtr%>"src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
    <%} // end for loop%>
  </table>
<%} //end vRetResult !=null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="iCtr" value="<%=iCtr%>">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
