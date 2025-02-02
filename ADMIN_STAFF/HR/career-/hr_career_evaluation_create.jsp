<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function ChangeRewardType(){
	document.staff_profile.labelname.value = document.staff_profile.award_type[document.staff_profile.award_type.selectedIndex].text;
	ReloadPage();
}
function viewInfo(){
	ReloadPage();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
}

function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewScholarshipList(strIndex,strAwardIndex)
{
	var loadPg = "./hr_updatescholarlist.jsp?labelName="+strIndex+"&awardIndex="+strAwardIndex;
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EditRecord(index)
{
	document.staff_profile.page_action.value="2";
}

function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}

function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.staff_profile.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.staff_profile.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		hideLayer(strTextBoxID);
		eval('document.staff_profile.'+strOthFieldName+'.disabled=true');
	}
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	ReloadPage();
}

function CancelRecord(index){
	location = "./hr_personnel_awards_etc.jsp?emp_id="+index;
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoScholarship" %>
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
Vector vRetResult = new Vector();
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = request.getParameter("info_index");

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strReloadPage = WI.getStrValue(request.getParameter("reloadpage"),"0");

HRInfoScholarship hrS = new HRInfoScholarship();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

strTemp = WI.fillTextValue("emp_id");

if (strTemp.length()!= 0){

	if( iAction == 0 || iAction  == 1 || iAction == 2)
	vRetResult = hrS.operateOnScholarship(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee education record removed successfully.";
				else
					strErrMsg = hrS.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee education record added successfully.";
				else
					strErrMsg = hrS.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee education record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrS.getErrMsg();
				break;
			}
		}
	}
}

if (strPrepareToEdit.compareTo("1") == 0){
	vRetResult = hrS.operateOnScholarship(dbOP,request,3);

	if (vRetResult != null && vRetResult.size() > 0){
		bSetEdit = true;
	}
}
%>
<body bgcolor="#663300">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          CAREER EVALUATION MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
        <br>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr>
            <td width="23%" height="25"><div align="left"><strong><font color="#0000FF" size="1">EVALUATION
                CRITERIA</font></strong></div></td>
            <td width="77%"> <select name="eval_criteria" id="eval_criteria" onChange='ChangeRewardType();'>
                <option value="">Select Evaluation Criteria</option>
<%
	strTemp = WI.fillTextValue("eval_criteria");
	if (bSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vRetResult.elementAt(2);
	}
%>
                <%=dbOP.loadCombo("REWARD_TYPE_INDEX","REWARD_NAME"," FROM HR_REWARD_TYPE",strTemp,false)%> </select>
              <strong><a href='javascript:viewList("HR_EVAL_CRITERIA","CRITERIA_INDEX","CRITERIA_NAME","EVALUATION CRITERIA");'><img src="../../../images/update.gif" border="0"></a>
              </strong><font size="1">click to add evaluation criteria</font></td>
          </tr>
          <tr>
            <td colspan="2"><hr size="1" color="blue"></td>
          </tr>
		  </table>
          <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr>
            <td height="25" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE
              MAIN ITEMS</font></strong></td>
          </tr>
          <tr>
            <td width="3%" height="25"><strong></strong></td>
            <td width="97%"><select name="select3">
              </select></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td><textarea name="textarea2" cols="40" rows="2"></textarea></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td><input name="image2" type="image" onClick="AddRecord();" src="../../../images/add.gif">
              <font size="1">click to add new ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click
              to edit ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click
              to delete selected ITEM</font></td>
          </tr>
          <tr>
            <td height="31" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE
              SUB ITEM UNDER MAIN ITEM &lt;$ITEM&gt;</font></strong></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td><select name="select4">
              </select></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td><textarea name="textarea3" cols="40" rows="2"></textarea></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td><input name="image22" type="image" onClick="AddRecord();" src="../../../images/add.gif">
              <font size="1">click to add new SUB ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click
              to edit SUB ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click
              to delete selected SUB ITEM</font></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr bgcolor="#CCCCCC">
            <td colspan="3"> <div align="center"><strong><font size="1">VIEW ALL
                ITEM - SUB-ITEM LISTING FOR EVALUATION CRITERIA &lt;$CRITERIA&gt;</font></strong></div></td>
          </tr>
          <tr>
            <td colspan="3">&nbsp;</td>
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
            <td align="center">
				<input name="textfield2" type= "text" class="textbox" size="10" maxlength="3"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>

        </table>

      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
</form>
</body>
</html>

