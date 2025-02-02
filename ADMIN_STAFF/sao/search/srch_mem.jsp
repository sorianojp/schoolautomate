<%@ page language="java" import="utility.*,osaGuidance.Organization,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Organization</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");	
}
function ReloadPage()
{
	document.form_.search_.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function SearchOrg()
{
	document.form_.search_.value = "1";
	document.form_.print_pg.value = "";
}

<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strOrgID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strOrgID;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
<%}%>
function focusID() {
	document.form_.organization_id.focus();
}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-organization","srch_org.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual    = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName       = {"Org. ID","Last Name","First Name"};
String[] astrSortByVal        = {"organization_id","lname","fname"};


int iSearchResult = 0;

Organization searchOrg = new Organization(request);
if(WI.fillTextValue("search_").equals("1")){
	vRetResult = searchOrg.searchMember(dbOP);
	if(vRetResult == null)
		strErrMsg = searchOrg.getErrMsg();
	else	
		iSearchResult = searchOrg.getSearchCount();
}

%>
<form action="./srch_mem.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH ORGANIZATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year </td>
      <td colspan="2">
<% strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
	  <input name="sy_from" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  		value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp="DisplaySYTo('form_','sy_from','sy_to')"> 
	   	<input type="hidden" name="cur_sy_from" 
			value="<%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%>">
        - 
<% strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>		
        &nbsp;
        <input name="sy_to" type="text" class="textbox" 
		 value="<%=strTemp%>" size="4" maxlength="4" readonly>
	   	<input type="hidden" name="cur_sy_to" 
			value="<%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%>">      </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Organization </td>
      <td colspan="2"><select name="org_index">
	  	<option value=""></option>
        <%=dbOP.loadCombo("organization_index", "organization_id",
							" from osa_organization  where is_del = 0 and is_valid = 1",
								WI.fillTextValue( "org_index"),false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Last Name </td>
      <td width="12%"><select name="org_name_con">
          <%=searchOrg.constructGenericDropList(WI.fillTextValue("org_name_con"),astrDropListEqual,astrDropListValEqual)%> 
      </select></td>
      <td width="72%"><input type="text" name="name" value="<%=WI.fillTextValue("name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>First Name </td>
      <td><select name="org_type_con">
          <%=searchOrg.constructGenericDropList(WI.fillTextValue("org_type_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input type="text" name="organization_type" value="<%=WI.fillTextValue("organization_type")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<!--    <tr> 
      <td height="25">&nbsp;</td>
      <td>Adviser</td>
      <td><select name="select">
          <%=searchOrg.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input type="text" name="fname2" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>-->
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Accredited</td>
      <td colspan="2">From 
        <input name="date_accr_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_accr_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_accr_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To 
        <input name="date_accr_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_accr_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_accr_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
-->
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">Sort by</td>
      <td width="25%"><select name="sort_by1" style="font-size:10px">
          <option value="">N/A</option>
          <%=searchOrg.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select></td>
      <td width="23%"><select name="sort_by2" style="font-size:10px">
          <option value="">N/A</option>
          <%=searchOrg.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select></td>
      <td width="40%"><select name="sort_by3" style="font-size:10px">
          <option value="">N/A</option>
          <%=searchOrg.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
          <%}else{%>
          <option value="desc">Desc</option>
          <%}%>
        </select></td>
      <td width="1%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="image" type="image" onClick="SearchOrg();" src="../../../images/form_proceed.gif"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" align="right"><!--<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print result</font>-->&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" height="25"><b> Total Organizations : <%=iSearchResult%> - Showing(<%=searchOrg.getDisplayRange()%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchOrg.defSearchSize;
		if(iSearchResult % searchOrg.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchStudent();">
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

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="13%" height="25" class="thinborder"><div align="center"><strong>ORG &nbsp;ID</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>ID NUMBER</strong> </div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>LAST NAME</strong>
      </div>
        <div align="center"><strong><font size="1"> </font></strong></div></td><td width="17%" class="thinborder"><div align="center"><strong>FIRST NAME</strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong>MIDDLE NAME </strong></div></td>
    </tr>
 <%
// 	System.out.println("vRetResult : " + vRetResult);

 	for(int i = 0; i < vRetResult.size(); i += 5){
%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><font size="1">
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> <%=(String)vRetResult.elementAt(i+1)%></a>
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%>
        <%}%>
      </font></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
    </tr>
 <%}//end of for loop.%>
  </table>
<%}//if vRetResult is not null. search result found.%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="print_pg">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>