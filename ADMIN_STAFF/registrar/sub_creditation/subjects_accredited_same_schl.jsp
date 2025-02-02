<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.subaccredited.submit();
}
function CancelRecord()
{
	location="./subjects_accredited_same_schl.jsp";
}
function ReloadPage()
{

	document.subaccredited.submit();
}
function PageAction(strInfoIndex,strAction) {
	document.subaccredited.page_action.value = strAction;
	document.subaccredited.info_index.value = strInfoIndex;
	document.subaccredited.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="subaccredited" action="./subjects_accredited_same_schl.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.AccreditedExtn,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-SUBJECT ACCREDITATION-Subject accridited","subjects_accredited_same_schl.jsp");
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
														"Registrar Management","SUBJECT UNITS CREDITATION",request.getRemoteAddr(),
														"subjects_accredited_same_schl.jsp");
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

AccreditedExtn accrExtn = new AccreditedExtn();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(accrExtn.operateOnSubjectAccreditation(dbOP, request, Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation successful.";
	else	
		strErrMsg = accrExtn.getErrMsg();
}

int iSearchResult = 0;
//get all levels created.
Vector vRetResult = null;
Vector vSub1Info  = null;
Vector vSub2Info  = null;

vRetResult = accrExtn.operateOnSubjectAccreditation(dbOP,request,3);
iSearchResult = accrExtn.iSearchResult;
if(vRetResult == null)
	strErrMsg = accrExtn.getErrMsg();

strTemp = WI.fillTextValue("sub_map1");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0) {
	vSub1Info = accrExtn.getSubDetail(dbOP,WI.fillTextValue("sub_map1"));
	if(vSub1Info == null)
		strErrMsg = accrExtn.getErrMsg();
}
strTemp = WI.fillTextValue("sub_map2");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0) {
	vSub2Info = accrExtn.getSubDetail(dbOP,WI.fillTextValue("sub_map2"));

	if(vSub1Info == null)
		strErrMsg = accrExtn.getErrMsg();
}

%>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SUBJECTS EQUIVALENTS - SAME SCHOOL PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"><a href="subjects_accredited_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="15%"><font size="1"><strong>SUB CODE </strong></font></td>
      <td width="50%" align="center"><div align="left"><font size="1"><strong>SUB 
          DESCRIPTION </strong></font></div></td>
      <td width="13%"><div align="left"><font size="1"><strong>LEC/LAB UNIT</strong></font></div></td>
      <td width="13%"><div align="left"><font size="1"><strong>LEC/LAB HOUR</strong></font></div></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td  height="27"><select name="sub_map1" onChange="ReloadPage();">
<option value="0">Select a subject</option>	  
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE"," from SUBJECT where IS_DEL=0 order by sub_code",
		  WI.fillTextValue("sub_map1") , false)%> 
        </select> </td>
	  <td>&nbsp;
	  <%
	  if(vSub1Info != null) {%>
	  <%=(String)vSub1Info.elementAt(1)%>
	  <%}%></td>
      <td>&nbsp; 
        <%
	  if(vSub1Info != null) {%>
        <%=WI.getStrValue(vSub1Info.elementAt(2),"&nbsp;")%>/<%=WI.getStrValue(vSub1Info.elementAt(3),"&nbsp;")%> 
        <%}%>
      </td>
      <td>&nbsp;
        <%
	  if(vSub1Info != null) {%>
        <%=WI.getStrValue(vSub1Info.elementAt(4),"&nbsp;")%>/<%=WI.getStrValue(vSub1Info.elementAt(5),"&nbsp;")%> 
        <%}%>
      </td>
      <td>&nbsp; </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td  height="27"><font color="#0000FF" size="1" ><strong>EQUIV. SUBJECT 
        CODE</strong></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td  height="27"><select name="sub_map2" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE"," from SUBJECT where IS_DEL=0 order by sub_code",
		  WI.fillTextValue("sub_map2") , false)%> </select></td>
      <td> 
        <%
	  if(vSub2Info != null) {%>
        <%=(String)vSub2Info.elementAt(1)%> 
        <%}%>
      </td>
      <td>&nbsp; 
        <%
	  if(vSub2Info != null) {%>
        <%=WI.getStrValue(vSub2Info.elementAt(2),"&nbsp;")%>/<%=WI.getStrValue(vSub2Info.elementAt(3),"&nbsp;")%> 
        <%}%>
      </td>
      <td>&nbsp; 
        <%
	  if(vSub2Info != null) {%>
        <%=WI.getStrValue(vSub2Info.elementAt(4),"&nbsp;")%>/<%=WI.getStrValue(vSub2Info.elementAt(5),"&nbsp;")%> 
        <%}%>
      </td>
      <td> 
        <%
if(iAccessLevel > 1 && vSub2Info != null){%>
        <a href='javascript:PageAction("",1);'><img src="../../../images/add.gif" border="0"></a> 
        <%}else if(vSub2Info != null){%>
		N/A
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="6" valign="middle"><hr size="1"></td>
    </tr>
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center"><strong>LIST OF EXISTING 
          SUBJECTS EQUIVALENT(S)</strong></div></td>
    </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

<table width="100%" border="0" bgcolor="#FFFFFF">
<tr>
      <td width="66%" ><b>
        Total Result : <%=iSearchResult%> - Showing(<%=accrExtn.strDispRange%>)</b></td>
      <td width="34%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/accrExtn.defSearchSize;
		if(iSearchResult % accrExtn.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right">Jump
          To page:
          <select name="jumpto" onChange="goToNextSearchPage();">

		<%
			strTemp = WI.fillTextValue("jumpto");
			if(strTemp.length() ==0) strTemp = "0";

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

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="30%"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="15%"><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT CODE</font></strong></td>
      <td width="30%"><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT TITLE</font></strong></td>
      <td width="8%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); i += 5)
{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=(String)vRetResult.elementAt(i+3)%></td>
      <td><%=(String)vRetResult.elementAt(i+4)%></td>
      <td align="center"> 
        <%if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>
      </td>
    </tr>
    <%
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
 <table width="100%" bgcolor="#FFFFFF" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

  </form>
</body>
</html>


<%
dbOP.cleanUP();
%>
