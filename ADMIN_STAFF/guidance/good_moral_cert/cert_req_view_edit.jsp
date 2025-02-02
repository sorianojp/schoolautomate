<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function EditDetail(strInfoIndex, strStudIndex)
{
	location = "./cert_req_entry.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&prepareToEdit=1";
}
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDMoral, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrPurpose = {"School Transfer", "Employment", "Exam Requirement"};
	String[] astrStatus = {"Under Evaluation", "Given to student"};
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Good Moral Certification-View/Edit Certification","cert_req_view_edit.jsp");
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
														"Guidance & Counseling","Good Moral Certification",request.getRemoteAddr(),
														"cert_req_view_edit.jsp");
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Date Request"};
String[] astrSortByVal     = {"id_number","lname","fname","GD_MORAL_CERT.REQUEST_DATE"};

int iSearchResult = 0;
GDMoral GDMor = new GDMoral();

if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = GDMor.searchCertificate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = GDMor.getErrMsg();
	else	
		iSearchResult = GDMor.getSearchCount();
}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./cert_req_view_edit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: GOOD MORAL CERTIFICATION : VIEW/EDIT REQUEST 
          ENTRIES PAGE::::</strong></font></div></td>
    </tr>
	</table>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="20"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
	</table>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=GDMor.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="76%" colspan="3"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=GDMor.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=GDMor.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="4"><select name="c_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 "+
 										" order by c_name asc", request.getParameter("c_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr><tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
   		<td height="25">&nbsp;</td>
   		<td>Request Date</td>
   		<td colspan="4">
      	<input name="date_req_from" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_req_from")%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_req_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      	 to 
      	 <input name="date_req_to" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_req_to")%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_req_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
   </tr><tr>
      <td height="25">&nbsp;</td>
      <td height="25">Purpose </td>
      <td colspan="4" align="center"><div align="left">
          <%strTemp = (String)WI.fillTextValue("purpose_index");%>
        <select name="purpose_index">
            <option value="" selected>N/A</option>
            <% if (strTemp.compareTo("0")==0){%>
            <option value="0" selected>Transfer to other school</option>
            <%}else{%>
            <option value="0">Transfer to other school</option>
            <%} if (strTemp.compareTo("1")==0){%>
            	<option value="1" selected>For employment</option>
			<%}else{%>
				<option value="1">For employment</option>
			<%} if (strTemp.compareTo("2")==0){%>
	            <option value="2" selected>Examination requirement</option>
	        <%}else{%>
	        	<option value="2">Examination requirement</option>
	        	<%}%>
          </select>
        </div></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">Status </td>
      <td colspan="4" align="center"><div align="left"> 
          <%strTemp = (String)WI.fillTextValue("status_index");%>
        <select name="status_index">
        	<option value="" selected>N/A</option>
            <% if (strTemp.compareTo("0")==0){%>
            <option value="0" selected>Under evaluation</option>
            <%}else{%>
            <option value="0">Under evaluation</option>
            <%} if (strTemp.compareTo("1")==0){%>
            	<option value="1" selected>Given to student</option>
			<%}else{%>
				<option value="1">Given to student</option>
			<%}%>
          </select>
        </div></td>
    </tr>
    <tr>
    <td colspan="6" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="10%">Sort by</td>
      <td width="25%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=GDMor.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=GDMor.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="37%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=GDMor.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <br/>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="24" colspan="7" class="thinborder"><div align="center"><font color="#000000">LIST 
          OF STUDENTS WHO REQUESTED FOR GOOD MORAL CERTFICATION</font></div></td>
    </tr>
   <tr>  
   <td height="25" colspan="4" class="thinborder"><strong><font size="1">
		  TOTAL EMPLOYEE(S) : <%=iSearchResult%> - Showing(<%=GDMor.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="3" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/GDMor.defSearchSize;
		if(iSearchResult % GDMor.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="SearchApplicant();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%></td>
    </tr><tr> 
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">DATE REQUESTED</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">STUDENT ID</font></strong></div></td>
      <td width="21%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
          NAME</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong><font size="1">PURPOSE</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
       <td width="5%" class="thinborder"><div align="center"><strong><font size="1">&nbsp;</font></strong></div></td>
    </tr>
   <%for (int i = 0; i<vRetResult.size(); i+=9){%>
    <tr> 
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=astrPurpose[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></td>
       <td class="thinborder"><font size="1"><%=astrStatus[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></font></td>
      <td class="thinborder"><a href='javascript:EditDetail(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+2))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
 <input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
