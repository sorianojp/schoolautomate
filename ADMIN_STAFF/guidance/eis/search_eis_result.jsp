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
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "./mental_ability_detail.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
function ShowHideRange2()
{
	if(document.form_.score_con.selectedIndex == 3)
		showLayer('rank2_');		
	else
		hideLayer('rank2_');
}
function ShowHideAge2()
{
	if(document.form_.age_con.selectedIndex == 3)
		showLayer('age2_');		
	else
		hideLayer('age2_');
}
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDEQ, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String[] astrGender = {"Male", "Female"};

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Emotional Intelligence Scale-Search","search_eis_result.jsp");
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
														"Guidance & Counseling","Emotional Intelligence Scale",request.getRemoteAddr(),
														"search_eis_result.jsp");
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
String[] astrSortByName    = {"Employee ID","Lastname","Firstname","Gender","College","Raw Score","EQ Dimension","Interpretation","Exam Date"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","COLLEGE.C_CODE","raw_score","EQ_DIMENSION","GD_EQ_INTERPRETATION.DESCRIPTION","exam_date"};


int iSearchResult = 0;
GDEQ GDEq = new GDEQ();

if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = GDEq.searchEQResult(dbOP, request);
	if(vRetResult == null)
		strErrMsg = GDEq.getErrMsg();
	else	
		iSearchResult = GDEq.getSearchCount();}
boolean bolSearchStud = false;
if(WI.fillTextValue("search_stud").compareTo("1") == 0) 
	bolSearchStud = true;
%>
<body bgcolor="#663300">
<form action="./search_eis_result.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: EQ RESULT SEARCH PAGE::::</strong></font></div></td>
    </tr>
</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Exam Date</td>
      <td colspan="4"> <input name="exam_date_fr" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("exam_date_fr")%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.exam_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="exam_date_to" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("exam_date_to")%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.exam_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%"><%if(!bolSearchStud){%>Employee<%}else{%>Student<%}%> ID </td>
      <td width="9%"><select name="id_number_con">
          <%=GDEq.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="14%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
      <td width="9%">Gender</td>
      <td width="47%"> <select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("0") ==0){%>
          <option value="0" selected>Male</option>
          <%}else{%>
          <option value="0">Male</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=GDEq.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=GDEq.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="3"><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
    </tr>
<%if(!bolSearchStud){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employment Status</td>
      <td colspan="3"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      <td>Emp. Type 
        <select name="emp_type_index" style="font-size:10px">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>College</td>
      <td colspan="4"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");
          if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
		else
				strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td colspan="4"><select name="d_index">
          <option value="">N/A</option>
          <%
			strTemp3 = "";
			strTemp3 = WI.fillTextValue("d_index");
			%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
 <%}//show for employee search only.%>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>

	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Age</td>
      <td height="25" colspan="4">
       <%strTemp = WI.fillTextValue("age_con");%>
      <select name="age_con" onchange="javascript:ShowHideAge2();">
			        <option value="0" selected>Equal to</option>
          <%if (strTemp.compareTo("1")==0){%>
        	    	<option value="1" selected>Younger than</option>
			<%}else{%>
					<option value="1">Younger than</option>
			<%} if (strTemp.compareTo("2")==0){%>
         			<option value="2" selected>Older than </option>
          <%}else{%>
                    <option value="2">Older than </option>
          <%} if (strTemp.compareTo("3")==0){%>
         			 <option value="3">Between</option>
          <%}else{%>
                    <option value="3">Between</option>
         <%}%>
        </select>
        <input name="age_from" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","age_from")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","age_from");style.backgroundColor="white"' value="<%=WI.fillTextValue("age_from")%>">
        &nbsp; 
       <input name="age_to" type="text" size="4" class="textbox" id="age2_" onKeyUp= 'AllowOnlyInteger("form_","age_to")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","age_to");style.backgroundColor="white"' value="<%=WI.fillTextValue("age_to")%>"></td>
	<script language="JavaScript">
		ShowHideAge2();
	</script>
    </tr>  
      <tr> 
      <td height="25">&nbsp;</td>
      <td>EQ Dimension</td>
      <td colspan="4"> 
      <%strTemp = WI.fillTextValue("dim_index");%>
      <select name="dim_index">
          <option value="">N/A</option>
			<%=dbOP.loadCombo("EQ_DIMENSION_INDEX","EQ_DIMENSION"," FROM GD_EQ_DIMENSION WHERE IS_VALID = 1 AND IS_DEL = 0 ORDER BY ORDER_NO", strTemp, false)%>
        </select></td>
    </tr>
      <tr> 
      <td >&nbsp;</td>
      <td >Raw Score</td>
      <td colspan="4">
      <%strTemp = WI.fillTextValue("score_con");%>
      <select name="score_con" onchange="javascript:ShowHideRange2();">
          <option value="0" selected>Equal to</option>
          <%if (strTemp.compareTo("1")==0){%>
        	    	<option value="1" selected>Less than</option>
			<%}else{%>
					<option value="1">Less than</option>
			<%} if (strTemp.compareTo("2")==0){%>
         			<option value="2" selected>Greater than</option>
          <%}else{%>
                    <option value="2">Greater than</option>
          <%} if (strTemp.compareTo("3")==0){%>
         			 <option value="3">Between</option>
          <%}else{%>
                    <option value="3">Between</option>
         <%}%>
         </select>
      <input name="rank1" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","rank1")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","rank1");style.backgroundColor="white"' value="<%=WI.fillTextValue("rank1")%>">
          &nbsp; 
      <input name="rank2" type="text" size="4" class="textbox" id="rank2_" onKeyUp= 'AllowOnlyInteger("form_","rank2")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","rank2");style.backgroundColor="white"' value="<%=WI.fillTextValue("rank2")%>">
		</td>
		<script language="JavaScript">
ShowHideRange2();
</script>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Interpretation</td>
      <td colspan="4"> 
      <%strTemp = WI.fillTextValue("inter_index");%>
      <select name="inter_index">
          <option value="">N/A</option>
			<%=dbOP.loadCombo("EQ_INT_INDEX","DESCRIPTION"," FROM GD_EQ_INTERPRETATION WHERE IS_VALID = 1 AND IS_DEL = 0 ORDER BY RANK1", strTemp, false)%>
        </select></td>
    </tr>
    <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="10%">Sort by</td>
      <td width="25%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=GDEq.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=GDEq.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="37%"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=GDEq.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp; 
	  <%
	  strTemp = WI.fillTextValue("search_stud");
	  if(strTemp.compareTo("1") == 0 )
	  	strTemp = " checked";
	  else	
	  	strTemp = "";
	%>
	  <input type="checkbox" name="search_stud" value="1"<%=strTemp%> onClick="ReloadPage();">
        <font color="#0000FF"><strong>Search student.</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult !=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          SEARCH RESULT</strong></font></div></td>
    </tr>
    <tr>
	      <td height="25" colspan="4" class="thinborder"><strong><font size="1">
		  TOTAL EMPLOYEE(S) : <%=iSearchResult%> - Showing(<%=GDEq.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="4" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/GDEq.defSearchSize;
		if(iSearchResult % GDEq.defSearchSize > 0) ++iPageCount;
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
    </tr>
    <tr> 
	  <td width="11%" class="thinborder"><div align="center"><font size="1"><strong><%if(bolSearchStud){%>STUDENT <%}else{%>EMPLOYEE <%}%>ID</strong></font></div></td>	
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>EXAM DATE</strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong><%if(bolSearchStud){%>STUDENT <%}else{%>EMPLOYEE <%}%>NAME</strong></font></div></td>
<%if(!bolSearchStud){%>
      <td width="16%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE/DEPARTMENT</strong></font></div></td>
<%}%>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>GENDER</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>RAW SCORE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>INTERPRETATION</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>EQ DIMENSION</strong></font></div></td>
    </tr>
	<%for (int i = 0; i<vRetResult.size(); i+=12){%>
    <tr> 
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td height="25" class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), (String)vRetResult.elementAt(i+6),7)%></font></td>
<%
if(!bolSearchStud){%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+7))%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></font></td>
<%}%>
      <td class="thinborder"><div align="center"><font size="1">
	  <%if(WI.fillTextValue("search_stud").compareTo("1") == 0) {%>
	  <%=(String)vRetResult.elementAt(i+9)%>
	  <%}else{%>
	  <%=astrGender[Integer.parseInt((String)vRetResult.elementAt(i+9))]%>
	  <%}%>
	  </font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+11)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
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
