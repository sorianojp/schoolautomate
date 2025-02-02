<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
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
<%@ page language="java" import="utility.*, osaGuidance.GDMentalAbility, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Mental Ability Test Result-Search","search_mental_ability.jsp");
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
														"Guidance & Counseling","Mental Ability Test Result",request.getRemoteAddr(),
														"search_mental_ability.jsp");
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
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course","Raw Score","IQ Class", "Exam Date"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","course_name","score","GD_IQ_CLASSIFICATION.CLASSIFICATION", "examination_date"};


int iSearchResult = 0;
GDMentalAbility GDAbility = new GDMentalAbility();

if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = GDAbility.searchMentalAbility(dbOP, request);
	if(vRetResult == null)
		strErrMsg = GDAbility.getErrMsg();
	else	
		iSearchResult = GDAbility.getSearchCount();
}

%>
<body bgcolor="#663300">
<form action="./search_mental_ability.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: MENTAL ABILITY RESULT SEARCH PAGE::::</strong></font></div></td>
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
          <%=GDAbility.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="8%">Gender </td>
      <td width="42%"><select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=GDAbility.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>SY-SEM</td>
      <td><input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=GDAbility.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>Year Level</td>
      <td><select name="year_level">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="4"><select name="major_index">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("course_index").length()>0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
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
      <td>IQ Class</td>
      <td colspan="4"><%strTemp = WI.fillTextValue("iq_class");%>
         <select name="iq_class">
          <option value="">N/A</option>
			<%=dbOP.loadCombo("IQ_CLASS_INDEX","CLASSIFICATION"," FROM GD_IQ_CLASSIFICATION ORDER BY CLASSIFICATION", strTemp, false)%>
        </select></td>
    </tr>
    <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="10%">Sort by</td>
      <td width="25%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=GDAbility.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
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
          <%=GDAbility.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
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
          <%=GDAbility.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
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
      <td height="25">&nbsp;</td>
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
      <td><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult !=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          SEARCH RESULT</strong></font></div></td>
    </tr>
    <tr>  
	      <td height="25" colspan="5" class="thinborder"><strong><font size="1">
		  TOTAL APPLICANT(S) : <%=iSearchResult%> - Showing(<%=GDAbility.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="5" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/GDAbility.defSearchSize;
		if(iSearchResult % GDAbility.defSearchSize > 0) ++iPageCount;
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
	  <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SY / TERM</strong></font></div></td>	
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>EXAM DATE</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="18%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          NAME </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>YEAR LEVEL</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>GENDER</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>RAW SCORE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>IQ CLASS</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong><font size="1">&nbsp;</font></strong></div></td>
    </tr>
	<%for (int i = 0; i<vRetResult.size(); i+=15){%>
    <tr> 
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+8)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+9)%>&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+10))]%></font></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+14)%></font></div></td>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+7),((String)vRetResult.elementAt(i+6)) + "/","",(String)vRetResult.elementAt(i+6))%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+11))%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></div></td>
      <td class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+1))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
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

