<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateDepartment()
{
	location ="../../registrar/curriculum/curriculum_non_acad_dept.jsp?parentURL=../../fee_assess_pay/remittance/remittance_type.jsp";
}
function PrepareToEdit(strInfoIndex)
{
	document.remittance.editRecord.value = 0;
	document.remittance.deleteRecord.value = 0;
	document.remittance.addRecord.value = 0;
	document.remittance.prepareToEdit.value = 1;
	document.remittance.reloadPage.value = 0;
	document.remittance.info_index.value = strInfoIndex;

	this.SubmitOnce("remittance");

}
function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=remittance";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord()
{
	if(document.remittance.prepareToEdit.value == 1)
	{
		EditRecord(document.remittance.info_index.value);
		return;
	}
	document.remittance.editRecord.value = 0;
	document.remittance.deleteRecord.value = 0;
	document.remittance.addRecord.value = 1;
	document.remittance.reloadPage.value = 1;
	this.SubmitOnce("remittance");
}
function EditRecord(strTargetIndex)
{
	document.remittance.editRecord.value = 1;
	document.remittance.deleteRecord.value = 0;
	document.remittance.addRecord.value = 0;
	document.remittance.reloadPage.value = 1;
	document.remittance.info_index.value = strTargetIndex;
	this.SubmitOnce("remittance");
}

function DeleteRecord(strTargetIndex)
{
	document.remittance.editRecord.value = 0;
	document.remittance.deleteRecord.value = 1;
	document.remittance.addRecord.value = 0;
	document.remittance.reloadPage.value = 1;
	document.remittance.info_index.value = strTargetIndex;
	document.remittance.prepareToEdit.value == 0;
	this.SubmitOnce("remittance");
}
function CancelRecord()
{
	location = "./remittance_type.jsp";
}
function ReloadPage(){

	document.remittance.editRecord.value = 0;
	document.remittance.deleteRecord.value = 0;
	document.remittance.addRecord.value = 0;
	document.remittance.reloadPage.value ="1";
	this.SubmitOnce("remittance");
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FARemittance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Remittance Type","remittance_type.jsp");
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
														"Fee Assessment & Payments","REMITTANCE",request.getRemoteAddr(),
														"remittance_type.jsp");
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



FARemittance faRemit = new FARemittance(dbOP);

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	strPrepareToEdit="0";
	if(faRemit.operateOnRemittanceType(dbOP,request,1) != null)
		strErrMsg = "Remittance type added successfully.";
	else
		strErrMsg = faRemit.getErrMsg();
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	strTemp = request.getParameter("editRecord"); 
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{	if(faRemit.operateOnRemittanceType(dbOP,request,2)!= null){
			strPrepareToEdit="0";
			strErrMsg = "Remittance type changed successfully.";
		}
		else
			strErrMsg = faRemit.getErrMsg();
	}else {
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";
			if(faRemit.operateOnRemittanceType(dbOP,request,0)!= null)
				strErrMsg = "Remittance type added successfully.";
			else
				strErrMsg = faRemit.getErrMsg();
		}
	}
}

//get all levels created.
Vector vEditInfo = null;
Vector vRetResult = null;
String strInfoIndex = WI.fillTextValue("info_index");
if(strPrepareToEdit.compareTo("1") ==0) //get here edit information.
{
	vEditInfo = faRemit.operateOnRemittanceType(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = faRemit.getErrMsg();
	else
		strInfoIndex = (String)vEditInfo.elementAt(0);
}

%>

<form name="remittance" method="post" action="./remittance_type.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          REMITTANCE TYPE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
<%
	if (strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0) 
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = WI.fillTextValue("remit_type_index");
%>

      <td>Remittance Type</td>
      <td><select name="remit_type_index" id="remit_type_index">
	  <option value="">Select Remittance Type</option>
	  <%=dbOP.loadCombo("preload_remit_index","preload_remit_name", " from preload_remittance order by preload_remit_name",strTemp,false)%> 
	  </select>
        <strong><a href='javascript:viewList("PRELOAD_REMITTANCE","PRELOAD_REMIT_INDEX","PRELOAD_REMIT_NAME","TYPE OF REMITTANCES");'><img src="../../../images/update.gif" border="0"></a> 
        </strong><font size="1">click to add/edit remittance type</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Account Name</td>
      <td width="81%"><strong> 
<%
	if (strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0) 
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("remit_type");
%>
    <input name="remit_type" type="text" size="32" value="<%=strTemp%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>In-charge</td>
      <td> <%
	if (strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("incharge");
%> <input name="incharge" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College : </td>
      <td height="25"><strong> 
<%	String strCollegeIndex = "";

	if (strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0) {
		if (WI.fillTextValue("reloadPage").compareTo("0") == 0)
			strCollegeIndex = (String)vEditInfo.elementAt(5);
		else
			strCollegeIndex = WI.fillTextValue("c_index");	
	}
	else
		strCollegeIndex = WI.fillTextValue("c_index");
%>
        <select name="c_index" id="office" onChange="ReloadPage();">
          <option value="">Select a College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc ", strCollegeIndex, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Department</td>
      <td> <%

	
	if (strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0) {
		if (WI.fillTextValue("reloadPage").compareTo("0") == 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else
			strTemp = WI.fillTextValue("d_index");
	} else
		strTemp = WI.fillTextValue("d_index");
%> 
	<select name="d_index" id="select" onChange="ReloadPage()">
          <% if (strCollegeIndex !=null && strCollegeIndex.length() != 0) {%>
          <option value="">Select a Department</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and c_index = " + strCollegeIndex + " order by d_name asc", strTemp, false)%> 
          <%}else{%>
          <option value="">Select an Office</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and (c_index is null or c_index=0) order by d_name asc", strTemp, false)%> 
          <%}%>
        </select> <a href="javascript:UpdateDepartment();"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">Click 
        here to update non acad departments</font></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td>
	  <%	if (!(strPrepareToEdit.compareTo("1") == 0 && vEditInfo != null && vEditInfo.size() > 0)){%> 
	  <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> <%}else{%> <a href="javascript:EditRecord(<%=(String)vEditInfo.elementAt(0)%>);"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> <%}%> </td>
    </tr>
    <%}//if iAccessLevel > 1%>
    <tr> 
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST 
          OF REMITTANCES </strong></div></td>
    </tr>
    <% vRetResult = faRemit.operateOnRemittanceType(dbOP,request,4);
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr> 
      <td width="13%" align="center" class="thinborder"><strong><font size="1">REMITTANCE TYPE</font></strong></td>
      <td width="22%" height="25" align="center" class="thinborder"><font size="1"><strong>ACCOUNT 
        NAME </strong></font></td>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">COLLEGE :: DEPARTMENT 
        </font></strong></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>IN-CHARGE</strong></font></div></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>EDIT</strong></font></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1"><strong>DELETE</strong></font></strong></div></td>
    </tr>
    <%
 for(int i = 0; i< vRetResult.size(); i+=9){%>
    <tr> 
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
	  <%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"");
		if (strTemp.length() > 0)
			strTemp +=WI.getStrValue((String)vRetResult.elementAt(i+4)," :: ","","");
		else
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp");
						
	  %>
	  
	  
	  
      <td align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
      <td align="center" class="thinborder"> <%if(iAccessLevel==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
    <% } // end for loop%>
    <%}//end of display list of remittance.%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloadPage">
<input type="hidden" name="deleteRecord" value="0">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
