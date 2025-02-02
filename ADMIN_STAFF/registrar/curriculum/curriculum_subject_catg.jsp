<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
//this is called when edit button is clicked -- it moves the value to be edited to the add and set variable
//prepareToEdit =1 - when the add button clicked - if prepareToEdit is set -- then it sets editRecord to 1 and
//addRecord to 0 otherwise, it set addRecord to 1; -- Complicated - huh? -- done to save edit page :D
function PrepareToEdit(strInfoIndex, strCName, strBreakageFee, strMultipleOCMap)
{
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 0;
	document.scatg.prepareToEdit.value = 1;

	document.scatg.catg_name.value = strCName;
	document.scatg.info_index.value = strInfoIndex;
	<%if(strSchoolCode.startsWith("CLDH")){%>
	if(strBreakageFee == "1")
		document.scatg.IS_BREAKAGE_FEE.selectedIndex = 1;
	else	
		document.scatg.IS_BREAKAGE_FEE.selectedIndex = 0;
	<%}%>
	
	if(strMultipleOCMap == '1' && document.scatg.multiple_oc_map)
		document.scatg.multiple_oc_map.checked = true;
	else if(document.scatg.multiple_oc_map)
		document.scatg.multiple_oc_map.checked = false;
		
	document.scatg.catg_name.focus();

}
function Cancel()
{
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 0;
	document.scatg.prepareToEdit.value = '';

	document.scatg.catg_name.value = '';
	document.scatg.info_index.value = '';
	if(document.scatg.multiple_oc_map)
		document.scatg.multiple_oc_map.checked = false;
		
	document.scatg.catg_name.focus();

}

function AddRecord()
{
	if(document.scatg.prepareToEdit.value == 1)
	{
		EditRecord(document.scatg.info_index.value);
		return;
	}
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 1;

	document.scatg.submit();
}
function EditRecord(strTargetIndex)
{
	document.scatg.editRecord.value = 1;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 0;

	document.scatg.info_index.value = strTargetIndex;
	document.scatg.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 1;
	document.scatg.addRecord.value = 0;

	document.scatg.info_index.value = strTargetIndex;
	document.scatg.prepareToEdit.value == 0;

	document.scatg.submit();
}


</script>

<body bgcolor="#D2AE72" onLoad="document.scatg.catg_name.focus();">
<%@ page language="java" import="utility.*,enrollment.CurriculumSCatg,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance -subject category","curriculum_subject_catg.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_subject_catg.jsp");
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

CurriculumSCatg SC = new CurriculumSCatg();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(SC.add(dbOP,request))
	{
		strErrMsg = "Subject added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SC.getErrMsg()%></font></p>
		<%
		return;
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(SC.edit(dbOP,request))
		{
			strErrMsg = "Subject edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=SC.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(SC.delete(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Subject deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=SC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = SC.viewall(dbOP);
dbOP.cleanUP();

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=SC.getErrMsg()%></font></p>
	<%
	return;
}
%>


<form name="scatg" method="post" action="./curriculum_subject_catg.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SUBJECT CATEGORY MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="3" height="25"><font size="3"><%=strErrMsg%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="21%" height="25"><a href="curriculum_subject.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td colspan="-1">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Subject category </td>
      <td colspan="-1"><input name="catg_name" type="text" size="48" class="textbox" maxlength="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%if(strSchoolCode.startsWith("CLDH")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Breakage Fee</td>
      <td>&nbsp;<select name="IS_BREAKAGE_FEE">
	  <option value="0">Not applicable</option>
	  <option value="1">Applicable</option>
	  </select></td>
    </tr>
<%}
if(strSchoolCode.startsWith("NU") || strSchoolCode.startsWith("CSAB") || strSchoolCode.startsWith("CIT") || 
strSchoolCode.startsWith("WNU") || strSchoolCode.startsWith("UL") || strSchoolCode.startsWith("FATIMA") || 
strSchoolCode.startsWith("UPH") || strSchoolCode.startsWith("CDD") || strSchoolCode.startsWith("SWU")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <input type="checkbox" name="multiple_oc_map" value="1">
      Is Multiple Fee Mapping Applicable (only one category can have this value) &nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2" height="25" style="font-size:9px;"> 
	  <%if(iAccessLevel > 1){%> 
	  	<a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a>Save entry/changes
	  	<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>Cancel/Clear entries.
	  <%}else{%>Not authorized to add/edit/delete <%}%> </td>
    </tr>
    <%
    if(strErrMsg != null)
    {%>
    <%}//this shows the edit/add/delete success info%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="76%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST
          OF EXISTING SUBJECT CATEGORIES</div></td>
    </tr>
  </table>
<%if(vRetResult != null){
boolean bolIsMultipleOCMap = true;%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#55bbFF"> 
      <td class="thinborder" width="48%"><div align="center"><font size="1"><strong>SUBJECT CATEGORY</strong></font></div></td>
<%if(strSchoolCode.startsWith("CLDH")){%>
      <td class="thinborder" width="15%"><div align="center"><font size="1"><strong>BREAKAGE FEE</strong></font></div></td>
<%}%>      <td height="25" class="thinborder" width="10%"><div align="center"><font size="1"><strong>EDIT</strong></font></div></td>
      <td class="thinborder" width="27%"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>
    <%for(int i = 0 ; i< vRetResult.size() ; i += 4){
	if(bolIsMultipleOCMap) {
		if(vRetResult.elementAt(i + 3).equals("0"))
			bolIsMultipleOCMap = false;
	}%>
    <tr <%if(bolIsMultipleOCMap){%> bgcolor="#CCCCCC"<%}%>> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
<%if(strSchoolCode.startsWith("CLDH")){%>
      <td class="thinborder"><div align="center">
	  <%if(vRetResult.elementAt(i + 2) == null || ((String)vRetResult.elementAt(i + 2)).compareTo("0") == 0) {%>&nbsp;
      <%}else{%>
	  	<img src="../../../images/tick.gif">
	  <%}%>
	  </div></td>
<%}%>      <td height="25" class="thinborder"> <div align="center"> 
          <%if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>","<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+1),"'","")%>","<%=(String)vRetResult.elementAt(i+2)%>","<%=(String)vRetResult.elementAt(i+3)%>");'>
		  <img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="center"> 
          <%if(iAccessLevel ==2){%>
          <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
          <%}%>
        </div></td>
    </tr>
    <%}//end of view all loops %>
  </table>

<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="0">
<input type="hidden" name="deleteRecord" value="0">

</form>
</body>
</html>
