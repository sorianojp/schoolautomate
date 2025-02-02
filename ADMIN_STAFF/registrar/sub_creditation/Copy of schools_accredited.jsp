<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.schaccredited.editRecord.value = 0;
	document.schaccredited.deleteRecord.value = 0;
	document.schaccredited.addRecord.value = 0;
	document.schaccredited.prepareToEdit.value = 0;

	document.schaccredited.donot_call_close_wnd.value = "1";

	document.schaccredited.submit();
}
function CancelRecord()
{
	document.schaccredited.donot_call_close_wnd.value = "1";
	location="./schools_accredited.jsp?parent_wnd="+document.schaccredited.parent_wnd.value;
}

function PrepareToEdit(strInfoIndex)
{
	document.schaccredited.editRecord.value = 0;
	document.schaccredited.deleteRecord.value = 0;
	document.schaccredited.addRecord.value = 0;
	document.schaccredited.prepareToEdit.value = 1;

	document.schaccredited.info_index.value = strInfoIndex;

	document.schaccredited.donot_call_close_wnd.value = "1";

	document.schaccredited.submit();
}
function AddRecord()
{
	if(document.schaccredited.prepareToEdit.value == 1)
	{
		EditRecord(document.schaccredited.info_index.value);
		return;
	}
	document.schaccredited.editRecord.value = 0;
	document.schaccredited.deleteRecord.value = 0;
	document.schaccredited.addRecord.value = 1;

	document.schaccredited.donot_call_close_wnd.value = "1";

	document.schaccredited.submit();
}
function EditRecord(strInfoIndex)
{
	document.schaccredited.editRecord.value = 1;
	document.schaccredited.deleteRecord.value = 0;
	document.schaccredited.addRecord.value = 0;

	document.schaccredited.info_index.value = strInfoIndex;

	document.schaccredited.donot_call_close_wnd.value = "1";

	document.schaccredited.submit();

}

function DeleteRecord(strInfoIndex)
{
	document.schaccredited.editRecord.value = 0;
	document.schaccredited.deleteRecord.value = 1;
	document.schaccredited.addRecord.value = 0;

	document.schaccredited.info_index.value = strInfoIndex;
	document.schaccredited.prepareToEdit.value == 0;

	document.schaccredited.donot_call_close_wnd.value = "1";

	document.schaccredited.submit();
}

function CloseWindow() {
	document.schaccredited.close_wnd_called.value = "1";
	eval("window.opener.document."+document.schaccredited.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.schaccredited.donot_call_close_wnd.value.length >0)
		return;
	if(document.schaccredited.close_wnd_called.value == "0") {
		eval("window.opener.document."+document.schaccredited.parent_wnd.value+".submit()");
		window.opener.focus();
	}
}
</script>



<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="schaccredited" action="./schools_accredited.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.Accredited,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-SUBJECT ACCREDITATION-Schools accridited","schools_accredited.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","SUBJECT ACCREDITATION",request.getRemoteAddr(),
							//							"schools_accredited.jsp");
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

Accredited accredited = new Accredited();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(accredited.addSCH(dbOP,request))
	{
		strErrMsg = "School added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=accredited.getErrMsg()%></font></p>
		<%
		return;
	}
}
else//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(accredited.editSCH(dbOP,request))
		{
			strErrMsg = "School edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=accredited.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(accredited.delSCH(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "School deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=accredited.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}
// if prepareToEdit == 1; get school information to edit.
Vector vEditInfo = new Vector();
strTemp = request.getParameter("prepareToEdit");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{
	vEditInfo = accredited.viewOneSCH(dbOP,request.getParameter("info_index"));
	if(vEditInfo.size() ==0 || vEditInfo == null)
		strErrMsg = accredited.getErrMsg();
}



int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = accredited.viewAllSCH(dbOP,request);
dbOP.cleanUP();

iSearchResult = accredited.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=accredited.getErrMsg()%></font></p>
	<%
	return;
}

%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SCHOOLS ACCREDITED PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <%
if(WI.fillTextValue("parent_wnd").length() >0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> 
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
    <%}%>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="17%">School code: </td>
      <td width="80%"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = "";
%> <input name="sch_code" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>School name: </td>
      <td> 
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = "";
%> <input name="sch_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Type</td>
      <td><select name="sch_type">
	  <option value="0">Public</option>
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = "";
	if(strTemp.compareTo("1") == 0) {%>	  
	<option value="1" selected>Private</option>
<%}else{%>
	<option value="1">Private</option>
<%}if(strTemp.compareTo("2") == 0) {%>
	  <option value="2" selected>Semi Private/public</option>
<%}else{%>
	  <option value="2">Semi Private/public</option>
<%}%>
	  </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >School Address: </td>
      <td> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = "";
%> <textarea name="sch_addr" cols="32" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea> 
        <%
	strTemp = request.getParameter("prepareToEdit");
	if(strTemp == null) strTemp = "0";
	if(strTemp.compareTo("0") == 0)
	{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel</font> <%}%> </td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp; </td>
    </tr>
    <%
    if(strErrMsg != null)
    {%>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="2"><font size="3"><%=strErrMsg%></font></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center">LIST
          OF EXISTING SCHOOLS ACCREDITED</div></td>
    </tr>
</table>

<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" ><b> Total Schools : <%=iSearchResult%> - Showing(<%=accredited.strDispRange%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/accredited.defSearchSize;
		if(iSearchResult % accredited.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="13%" height="25" class="thinborder"><font size="1"><strong>&nbsp;SCHOOL 
        CODE</strong></font></td>
      <td width="32%" class="thinborder"><font size="1"><strong>SCHOOL NAME</strong></font></td>
      <td width="14%" class="thinborder"><font size="1"><strong>SCHOOL TYPE</strong></font></td>
      <td width="26%" class="thinborder"><font size="1"><strong>ADDRESS</strong></font></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i) {%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
    </tr>
    <%
i = i+4;
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
 <table width="100%" cellpadding="0"  cellspacing="0" >
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<%
strTemp = request.getParameter("prepareToEdit");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="prepareToEdit" value="<%=strTemp%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">	
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
  </form>
</body>
</html>
