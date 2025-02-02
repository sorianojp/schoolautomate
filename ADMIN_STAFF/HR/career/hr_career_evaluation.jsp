<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoGAExtraActivityOffense"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
}

function viewInfo(){
	document.staff_profile.page_action.value = "3";
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.submit();
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function CancelRecord(index)
{
	location = "./hr_personnel_affiliations.jsp?emp_id="+index;
}

function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

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
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_education.jsp");
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

Vector vEmpRec = new Vector();
Vector vRetResult = new Vector();
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = request.getParameter("info_index");

HRInfoGAExtraActivityOffense hrCon = new HRInfoGAExtraActivityOffense();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

strTemp = WI.fillTextValue("emp_id");

if (strTemp.trim().length()> 1){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");


	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnGroupAffiliation(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee group affiliation record removed successfully.";
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee group affiliation record added successfully.";
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee group affiliation record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0){
	vRetResult = hrCon.operateOnGroupAffiliation(dbOP,request,3);

	bNoError = false;

	if (vRetResult != null && vRetResult.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CAREER EVALUATION (TEACHING/NON-TEACHING) RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="37%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox" id="emp_id"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="58%"><input name="image2" type="image" onClick="viewInfo();" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
  <%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">

    <tr> 
      <td height="25"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> </td>
          </tr>
        </table>
        <br>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td colspan="2"><div align="center"><strong>ITEMS</strong></div></td>
            <td width="13%"><div align="center"><strong>POINTS</strong></div></td>
          </tr>
          <tr bgcolor="#CCCCCC"> 
            <td colspan="3"><strong><font color="#FF0000">SECTION 
              I - PERFORMANCE FACTORS</font></strong> <div align="center"></div></td>
          </tr>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="84%" onMouseOver="" onMouseOut=""><strong>Job Knowledge</strong> 
              <font size="1">( The extent the employee knows and understand the 
              details and nature of his assigned job and related duties)</font></td>
            <td align="center"><select name="select2">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Quality of Work </strong><font size="1">(The extent of 
              accuracy, completeness, orderliness, and neatness of the job perform.)</font></td>
            <td align="center"><select name="select3">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Quantity of Work</strong> <font size="1">( The amount 
              of acceptable work accomplished, and the ability to complete work 
              within time schedule)</font></td>
            <td align="center"><select name="select4">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Dependability </strong><font size="1">( The degree of 
              which employee can be depended upon to carry out the instructions, 
              be on the job, fulfill responsibilities, and ability to work with 
              minimum supervision.)</font></td>
            <td align="center"><select name="select2">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Judgement</strong> <font size="1">(The extent to which 
              his actions are based on facts, sound reasoning and good common 
              sense.)</font> </td>
            <td align="center"><select name="select3">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Creativity</strong> <font size="1">(Originality the ability 
              to think and perform new and innovative things towards the improvement 
              of present methods or add existing knowledge.)</font></td>
            <td align="center"><select name="select4">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Organization </strong><font size="1">(The ability to plan 
              and organize work effectively)</font></td>
            <td align="center"><select name="select2">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Initiative</strong> <font size="1">( The extent to which 
              the employee is a self-starter in attaining the objectives of his 
              job.)</font></td>
            <td align="center"><select name="select3">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Industrious</strong> <font size="1">(The extent to which 
              the employee may be described as a hard worker and the amount of 
              concentration and effort exerted in the performance of his job.)</font></td>
            <td align="center"><select name="select4">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Attaining Objectives</strong> <font size="1">(Overall 
              extend to which employee successfully accomplished the task or functions 
              assigned or delivered the desired results.)</font> </td>
            <td align="center"><select name="select5">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td colspan="3">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="#CCCCCC"><strong><font color="#FF0000">SECTION 
              II - PERSONAL QUALITIES AND MOTIVATIONS</font></strong></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Attitudes Towards Work and the Company</strong> <font size="1">(The 
              nature of the employee's feeling about the University; his interest 
              and the job.)</font></td>
            <td align="center"><select name="select4">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Attitudes Toward Attendance</strong> <font size="1">(Nature 
              of the employee's feelings towards lost ime for work.)</font></td>
            <td align="center"><select name="select2">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Cooperation </strong><font size="1">(The extent of employee's 
              cooperation with others including the ability to act jointly with 
              supervisors and/or executives for the benefit of the university.)</font></td>
            <td align="center"><select name="select3">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>Personality</strong> <font size="1">( The employee's effect 
              on others as a result of the totality of his personal and social 
              traits such as disposition, tact, enthusiasm, appearance, conduct 
              and others.)</font></td>
            <td align="center"><select name="select4">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><strong>General Appearance and Bearing</strong> <font size="1">(The 
              employee's manner of carrying out himself, dress and physical appearance; 
              neatness, appropriateness of dress).</font></td>
            <td align="center"><select name="select5">
                <option>0</option>
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>4</option>
                <option>5</option>
                <option>6</option>
                <option>7</option>
                <option>8</option>
                <option>9</option>
                <option>10</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> <div align="right"><strong>GRAND TOTAL &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
            <td align="center"><input name="textfield2" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="3"></td>
          </tr>
          <tr> 
            <td colspan="3"><p align="center"><font color="#FF0000"><strong>COMMENTS<br>
                <textarea name="textarea" cols="64" rows="10"></textarea>
                </strong></font></p>
              <table width="75%" border="0" align="center" cellpadding="3" cellspacing="3">
                <tr> 
                  <td width="45%">Evaluator ID: 
                    <input type="text" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="textfield323"></td>
                  <td width="55%">Date of Evaluation: 
                    <input type="text" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="textfield3">
                    <img src="../../../images/calendar_new.gif" border="0"></td>
                </tr>
                <tr> 
                  <td>Period From: 
                    <input type="text" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="textfield32"></td>
                  <td>Period To: <input type="text" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" name="textfield322"> 
                  </td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td colspan="3"><div align="center"> 
                <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
                <font size="1">click to save entries</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click 
                to save changes</font> <img src="../../../images/cancel.gif" width="51" height="26" border="0"><font size="1">click 
                to cancel and clear entries</font> </div></td>
          </tr>
        </table> 
		</td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>