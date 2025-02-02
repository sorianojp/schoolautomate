<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
	
	boolean bolIsSchool = false;

	if ((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" SRC="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
<!--
function PrintPage(){
	document.staff_profile.print_page.value="1";
	this.SubmitOnce("staff_profile");	
}
function ReloadPage(strInt){
	document.staff_profile.show_all.value = strInt;
	document.staff_profile.print_page.value="";
	this.SubmitOnce("staff_profile");
}

function ShowPage(){
	document.staff_profile.show_all.value ="1";
	document.staff_profile.print_page.value="";
	this.SubmitOnce("staff_profile");
}

function ViewDetail(emp_id, index) {
	var pgLoc = "./training_request_appl_detail.jsp?info_index="+index+"&emp_id="+emp_id+
	"&my_home="+document.staff_profile.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EditRequest(emp_id, info_index) {
	var pgLoc = "./training_request_application.jsp?prepareToEdit=1&is_forwarded=1&emp_id="+emp_id+"&info_index="+info_index;
	var win=window.open(pgLoc,"EditRequest",'dependent=yes,width=900,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

//add security hehol.
	if (WI.fillTextValue("print_page").compareTo("1") ==0){ %>
		<jsp:forward page="./training_request_application_view_print.jsp" />
<%	return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Request For Trainings","training_request_application_view.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REQUEST FOR TRAININGS",request.getRemoteAddr(),
														"training_request_application_view.jsp");
// added for CLDH
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//					
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
Vector vRetResult = null;
String strInfoIndex = request.getParameter("info_index");


if (bolIsSchool) 
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName = {"Employee ID","Lastname","Firstname",strTemp,"Office","Category","Type","Status"};
String[] astrSortByVal  = {"id_number","lname","fname","c_code","d_name","is_internal","seminar_type",
							  "TRNG_APPL_STAT"};
							  
							  
int iSearchResult = 0;
							  
HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining(request);

if (WI.fillTextValue("show_all").equals("1")) {
	vRetResult = hrCon.searchTrngAppl(dbOP);
	if (vRetResult == null) 
		strErrMsg  = hrCon.getErrMsg();
	else
		iSearchResult = hrCon.getSearchCount();
}
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./training_request_application_view.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        VIEW TRAINING APPLICATION REQUEST(S) PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="25">Category :</td>
      <td width="33%" height="25"><select name="trng_catg" id="trng_catg">
          <option value=""> ALL </option>
          <% if (WI.fillTextValue("trng_catg").compareTo("0") == 0) {%>
          <option value="0" selected>Internal (Held inside the school campus)</option>
          <%}else{%>
          <option value="0">Internal (Held inside the campus)</option>
          <%} if ( WI.fillTextValue("trng_catg").compareTo("1") == 0) {%>
          <option value="1" selected>External (Held outside the campus)</option>
          <%}else {%>
          <option value="1">External (Held outside the campus)</option>
          <%}%>
        </select></td>
      <td width="7%">&nbsp;&nbsp;Type :</td>
      <td width="44%"><select name="trng_type">
          <option value="">N/A</option>
          <% if (WI.fillTextValue("trng_type").compareTo("1") == 0) {%>
          <option value="1" selected>Official Time </option>
          <%}else{%>
          <option value="1">Official Time </option>
          <%} if (WI.fillTextValue("trng_type").compareTo("2") == 0) {%>
          <option value="2" selected>Official Business</option>
          <%}else{%>
          <option value="2">Official Business</option>
          <%} if (WI.fillTextValue("trng_type").compareTo("3") == 0) {%>
          <option value="3" selected>Representative/Proxy</option>
          <%}else{%>
          <option value="3">Representative/Proxy</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">Employee ID: </td>
      <td height="25">
	 <% if (WI.fillTextValue("my_home").equals("1"))
	 		strTemp = (String)request.getSession(false).getAttribute("userId");
		else
			strTemp = WI.fillTextValue("emp_id");
	  %>
	  <input name="emp_id" type="text" class="textbox" id="emp_id" size="16" maxlength="16"  
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
			value="<%=strTemp%>" <%if(bolMyHome){%> readonly <%}%>>
	  </td>
      <td height="25">&nbsp;&nbsp;Stat :</td>
      <td height="25"><select name="appl_stat">
		  <option value=""> All Request </option>
          <%  strTemp = WI.getStrValue(request.getParameter("appl_stat"));
	if (strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Pending/On-process</option>
		  <%}else{%>
		  <option value="2">Pending/On-process</option>
		  <%}if (strTemp.compareTo("3")==0){%>	
          <option value="3" selected>Pending - For Approval by 2nd Signatory</option>
          <%}else{%>
          <option value="3">Pending - For Approval by 2nd Signatory </option>
          <%}if (strTemp.compareTo("4") == 0){%>
          <option value="4" selected>Pending- For Approval by 3rd Signatory</option>
          <%}else{%>
          <option value="4">Pending - For Approval by 3rd Signatory</option>
          <%} if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Approved</option>
          <%}else{%>
          <option value="1">Approved</option>
          <%} if (strTemp.compareTo("0") == 0){%>
          <option value="0" selected>Disapproved</option>
          <%}else{%>
          <option value="0">Disapproved</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 

      <td height="25"><%if(bolIsSchool){%>College:<%}else{%>Division:<%}%></td>
      <td height="25" colspan="3"> <select name="c_index" id="c_index" onChange="ReloadPage(0)">
          <option value="">ANY</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0 order by c_name",WI.fillTextValue("c_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="25"><div align="left">Office /Dept. : </div></td>
      <td height="25" colspan="3"> <% if (WI.fillTextValue("c_index").length() == 0) strTemp = " c_index is null or c_index = 0";
	else strTemp = "c_index = " + WI.fillTextValue("c_index");%> <select name="d_index" id="d_index">
          <option value=""> Select Office/Dept </option>
          <%=dbOP.loadCombo("d_index","d_name", " from department where " + strTemp + "  and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="23">Date Filed :</td>
      <td height="23" colspan="3">From : 
        <input name="date_from" type="text" class="textbox"  onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_from','/')" 
		onfocus="style.backgroundColor='#D3EBFF'" 
		onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','date_from','/')"  
		value="<%=WI.fillTextValue("date_from")%>" size="10" maxlength="10" > 
        <a href="javascript:show_calendar('staff_profile.date_from');" title="Click to select date" 
		onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_to','/')" 
		 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','date_to','/')"  
		value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10" > <a href="javascript:show_calendar('staff_profile.date_to');" title="Click to select date" 
		onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="4"> <hr size="1"> </td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"><strong>&nbsp;&nbsp;<u>Sort by:</u></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"> &nbsp; <select name="sort_by1">
          <option value="">N/A</option>
          <%=hrCon.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp;&nbsp; <select name="sort_by2">
          <option value="">N/A</option>
          <%=hrCon.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp;&nbsp; <select name="sort_by3">
          <option value="">N/A</option>
          <%=hrCon.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="7%" height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ShowPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
<% if (vRetResult != null) {%>
  <table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td> <input name="show_all_res" type="checkbox"  value="1">
        check to show all result </td>
      <td><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0" ></a><font size="1">click 
          to print list</font></div></td>
    </tr>
    <tr>
      <td><b>TOTAL RESULT: <%=iSearchResult%> 
	  			<% if (WI.fillTextValue("show_all_res").compareTo("1") != 0) {%>
				- Showing(<%=hrCon.getDisplayRange()%>) <%}%></b></td>
      <td>
        <%
		if (WI.fillTextValue("show_all_res").compareTo("1") !=0) {
		
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = 0;
		
		
			iPageCount = iSearchResult/hrCon.defSearchSize ;
		
		if(iSearchResult % hrCon.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="ReloadPage(1);">
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
          <%}
		  } // if WI.filltextValue("show_all") %>
        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#666666"> 
      <td height="28" colspan="9" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
          OF TRAINING/SEMINAR REQUEST(S)</strong></font></td>
    </tr>
    <tr> 
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE ID</strong></font></td>
      <td width="19%" height="25" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="20%" height="25" align="center" class="thinborder"> <font size="1"><strong>
			 <%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> 
				/DEPT
      </strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>CATEGORY</strong></font></td>
      <td width="8%" height="25" align="center" class="thinborder"><font size="1"><strong>TYPE 
        <br>
        (BUDGET)</strong></font></td>
      <td width="8%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE 
        FILED </strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>INCLUSIVE DATES 
      </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>OPTION</strong></font></td>
    </tr>
<% 
	String[] astrIsInternal={"Internal", "External"};
	String[] astrType={"&nbsp;", "Official Time","Official Bus.","Rep. / Proxy" };
	String[] astrStat ={"Disapproved","Approved","Pending", "Pending - VP", "Pending - Pres"};
	
	for (int i =0; i < vRetResult.size() ; i+=14){%>
    <tr> 
      <td width="8%" height="32" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td width="17%" class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+8),
	  							(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),4)%></td>
	 <% if ((String)vRetResult.elementAt(i+11) != null){
	 	strTemp = (String)vRetResult.elementAt(i+11) + WI.getStrValue((String)vRetResult.elementAt(i+12)," :: ", "","");
	 } else strTemp = (String)vRetResult.elementAt(i+12);%>
    
      <td width="17%" class="thinborder"><%=strTemp%></td>
      <td width="7%" class="thinborder"><%=astrIsInternal[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"))]%></td>
      <td width="8%" class="thinborder">&nbsp;<%=/**astrType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"))]**/
	   WI.getStrValue((String)vRetResult.elementAt(i+4), "") + 
										  WI.getStrValue((String)vRetResult.elementAt(i+13),"<br>(",")","")%></td>
      <td width="8%" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="12%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%> <%=WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","")%> </td>
      <td width="8%" class="thinborder"><%=astrStat[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"2"))]%></td>
      <td width="8%" align="center" class="thinborder"><div align="center">
	  	<a href="javascript:ViewDetail('<%=(String)vRetResult.elementAt(i+7)%>','<%=(String)vRetResult.elementAt(i)%>')">
			<img name="image2" src="../../../images/view.gif"  border="0"></a>
		<%
		//status => 0 (disapproved), 1 (approved), 2 (Pending/On-process), 
		//3 (Pending/On-process - Recommends Approval by Vice-President concerned), 
		//4 (Pending/On-process - Recommends Approval by President)
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"2");
		//if not approved and not disapproved, meaning pending, then allow update..
		//only allow edit if pending, pending for VP, or pending for president
		//and if this is not accessed from myHome
		if(!strTemp.equals("0") && !strTemp.equals("1") && iAccessLevel > 1){%>
			<a href="javascript:EditRequest('<%=(String)vRetResult.elementAt(i+7)%>', '<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
		<%}%>
		</div></td>
    </tr>
<%} // end for loop %>
  </table>
 <%} // end if vRetResult != null%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="right"></div></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="show_all" value="0">
<input type="hidden" name="print_page">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
