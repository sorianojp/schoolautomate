<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDIctc"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
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
	a {
	text-decoration: none;
	}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage(){
	this.SubmitOnce("form_");
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	this.SubmitOnce("form_");
}

function AddNewRecord(){
	document.form_.page_action.value="1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
var vConfirm = confirm(" Confirm Delete Record ");
	if (vConfirm){
		document.form_.page_action.value="0";
		this.SubmitOnce("form_");
	}
}

function CancelEdit()
{
	location = "./ched_form_ict_staff.jsp?sy_from=" + document.form_.sy_from.value + 
				"&sy_to=" + document.form_.sy_to.value;
}

function viewList(tablename,labelname,strFormField){
	var loadPg = "./ched_updatelist.jsp?tablename=" + tablename + "&labelname="+escape(labelname)+
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_ict_staff.jsp");
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


Vector vRetResult = null;
Vector vEditResult = null;
CHEDIctc cr = new CHEDIctc();


String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){
	if (cr.operateOnChedICTStaff(dbOP,request,0) != null){
		strErrMsg = " ICT Data remove successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnChedICTStaff(dbOP,request,1) != null)
		strErrMsg = " ICT Data saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cr.operateOnChedICTStaff(dbOP,request,2) != null){
		strErrMsg = " ICT Data updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}

if (strPrepareToEdit.equals("1")){
	vEditResult = cr.operateOnChedICTStaff(dbOP,request,3);
	if (vEditResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedICTStaff(dbOP,request,4);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}


String strHardTypeIndex =null;
String[] astrEmpTypeIndex = {"Programmers","System Analyst/Designer","LAN Administrator",
							 "Computer /EDP Operator",  "Database Administrator", 
							 "Instructor / Professor"} ;
%>
<body>
<form name="form_" action="./ched_form_ict_staff.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED 
          ICT FORM STAFF ENTRY</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <!--DWLayoutTable-->
    <tr> 
      <td width="164" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="616"> &nbsp; <% 
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(1);
	else
		strTemp = WI.fillTextValue("sy_from");
	
	if (strTemp.length()  < 4){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        to 
        <% 
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("sy_to");
	
	if (strTemp.length() < 4 ){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; <input type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Employee Type</td>
      <td> &nbsp; <% 		
			if (vEditResult != null) 
				strTemp = (String) vEditResult.elementAt(3);
			else
				strTemp = WI.fillTextValue("emp_type_index");
	
	  %> <select name="emp_type_index">
          <option value="">Select Employment Type</option>
          <% for (int i = 0; i < astrEmpTypeIndex.length; ++i) {
				if (strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrEmpTypeIndex[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrEmpTypeIndex[i]%></option>
          <%}
		 }%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Number of Employees</td>
      <%
			if (vEditResult != null) 
				strTemp = WI.getStrValue((String) vEditResult.elementAt(4));
			else
				strTemp = WI.fillTextValue("num_staff");
	  %>
      <td>&nbsp; <input name="num_staff" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  	onKeyUP="AllowOnlyInteger('form_','num_staff')" size="3" maxlength="3"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">&nbsp; 
          <% if (iAccessLevel > 1)  {
		if (!strPrepareToEdit.equals("1")) {
%>
          <a href="javascript:AddNewRecord()"> <img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to save data </font> 
          <%}else{ %>
          <a href="javascript:EditRecord()"> <img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to update data</font> <a href="javascript:CancelEdit()"> 
          <img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel edit</font> 
          <%
		} // !strPrepareToEdit.equals("1")
 } // end iAccessLevel > 1
 %>
        </div></td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <br> <br>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="52%" height="25" class="thinborder"><div align="center"><strong>Position</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>No.</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>Options</strong></div></td>
    </tr>
    <% 
		String strNumEmp = null;
		int iIndex = 0;
		
		for(int i= 0; i <astrEmpTypeIndex.length; i++) {
		if (iIndex  < vRetResult.size() &&  
				i == Integer.parseInt((String)vRetResult.elementAt(iIndex+3))){
			strNumEmp = (String)vRetResult.elementAt(iIndex+4);
			//iIndex +=5;
		}else{
			strNumEmp = "";
		}
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=astrEmpTypeIndex[i]%></td>
      <td class="thinborder"><div align="center">&nbsp;<%=strNumEmp%></div></td>
      <td class="thinborder">&nbsp;
	  <% if (iAccessLevel > 1 && strNumEmp.length() > 0) { %> 
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(iIndex)%>')"><img src="../../../images/edit.gif" border="0"></a>
	  <% if (iAccessLevel == 2) {%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(iIndex)%>')"><img src="../../../images/delete.gif" border="0"></a>
	  <%}
	  	iIndex +=5;
	  }%>
	  </td>
    </tr>
    <%}%>
  </table>

 <% } // end if vRetResult %>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
